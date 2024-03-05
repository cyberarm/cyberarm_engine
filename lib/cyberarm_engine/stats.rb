module CyberarmEngine
  class Stats
    @frames = []
    @frame_index = -1
    @max_frame_history = 1024

    def self.new_frame
      if @frames.size < @max_frame_history
        @frames << Frame.new
      else
        @frames[@frame_index] = Frame.new
      end
    end

    def self.frame
      @frames[@frame_index]
    end

    def self.end_frame
      frame&.complete

      @frame_index += 1
      @frame_index %= @max_frame_history
    end

    def self.frames
      if @frames.size < @max_frame_history
        @frames
      else
        @frames.rotate(@frame_index - (@max_frame_history - (@frames.size - 1)))
      end
    end

    def self.frame_index
      @frame_index
    end

    def self.max_frame_history
      @max_frame_history
    end

    class Frame
      Timing = Struct.new(:start_time, :end_time, :duration)

      attr_reader :frame_timing, :counters, :timings, :multitimings
      def initialize
        @frame_timing = Timing.new(Gosu.milliseconds, -1, -1)
        @attempted_multitiming = false

        @counters = {
          gui_recalculations: 0
        }

        @timings = {}
        @multitimings = {}
      end

      def increment(key, number = 1)
        @counters[key] ||= 0
        @counters[key] += number
      end

      def start_timing(key)
        raise "key must be a symbol!" unless key.is_a?(Symbol)
        if @timings[key]
          # FIXME: Make it not spammy...
          # warn "Only one timing per key per frame. (Timing for #{key.inspect} already exists!)"
          @attempted_multitiming = true
          @multitimings[key] = true

          return
        end

        @timings[key] = Timing.new(Gosu.milliseconds, -1, -1)
      end

      def end_timing(key)
        timing = @timings[key]

        # FIXME: Make it not spammy...
        # warn "Timing #{key.inspect} already ended!" if timing.end_time != -1

        timing.end_time = Gosu.milliseconds
        timing.duration = timing.end_time - timing.start_time
      end

      def complete
        @frame_timing.end_time = Gosu.milliseconds
        @frame_timing.duration = @frame_timing.end_time - @frame_timing.start_time

        # Lock data structures
        @frame_timing.freeze
        @counters.freeze
        @timings.freeze
        @multitimings.freeze
      end

      def complete?
        @frame_timing.duration != -1
      end

      def attempted_multitiming?
        @attempted_multitiming
      end
    end

    class StatsPlotter
      attr_reader :position

      def initialize(x, y, z = Float::INFINITY, width = 128, height = 128)
        @position = Vector.new(x, y, z)
        @width = width
        @height = height

        @padding = 2
        @text_size = 16

        @max_timing_label = CyberarmEngine::Text.new("", x: x + @padding + 1, y: y + @padding, z: z, size: @text_size, border: true, static: true)
        @avg_timing_label = CyberarmEngine::Text.new("", x: x + @padding + 1, y: y + @padding + @height / 2 - @text_size / 2, z: z, size: @text_size, border: true, static: true)
        @min_timing_label = CyberarmEngine::Text.new("", x: x + @padding + 1, y: y + @height - (@text_size + @padding / 2), z: z, size: @text_size, border: true, static: true)

        @data_label = CyberarmEngine::Text.new("", x: x + @padding + @width + @padding, y: y + @padding, z: z, size: @text_size, border: true, static: true)

        @frame_stats = []
        @graphs = {
          frame_timings: []
        }
      end

      def calculate_graphs
        calculate_frame_timings_graph
      end

      def calculate_frame_timings_graph
        @graphs[:frame_timings].clear

        samples = @width - @padding
        nodes = Array.new(samples.ceil) { [] }

        slice = 0
        @frame_stats.each_slice((CyberarmEngine::Stats.max_frame_history / samples.to_f).ceil) do |bucket|
          bucket.each do |frame|
            nodes[slice] << frame.frame_timing.duration
          end

          slice += 1
        end

        max_node = CyberarmEngine::Stats.frames.select(&:complete?).map { |f| f.frame_timing.duration }.max
        scale = 1
        scale = (@height - @padding).to_f / max_node
        scale = 1 if scale > 1

        nodes.each_with_index do |cluster, i|
          break if cluster.empty?

          @graphs[:frame_timings] << CyberarmEngine::Vector.new(@position.x + @padding + 1 * i, (@position.y + @height - @padding) - cluster.max * scale)
        end
      end

      def draw
        @frame_stats = CyberarmEngine::Stats.frames.select(&:complete?)
        return if @frame_stats.empty?

        calculate_graphs

        @max_timing_label.text = "<c=d44>Max:</c> #{@frame_stats.map { |f| f.frame_timing.duration }.max.to_s.rjust(3, " ")}ms"
        @avg_timing_label.text = "<c=f80>Avg:</c> #{(@frame_stats.map { |f| f.frame_timing.duration }.sum / @frame_stats.size).to_s.rjust(3, " ")}ms"
        @min_timing_label.text = "<c=0d0>Min:</c> #{@frame_stats.map { |f| f.frame_timing.duration }.min.to_s.rjust(3, " ")}ms"

        Gosu.draw_rect(@position.x, @position.y, @width, @height, 0xaa_222222, @position.z)
        Gosu.draw_rect(@position.x + @padding, @position.y + @padding, @width - @padding * 2, @height - @padding * 2, 0xaa_222222, @position.z)

        draw_graphs

        @max_timing_label.draw
        @avg_timing_label.draw
        @min_timing_label.draw

        # TODO: Make this optional
        draw_timings_and_counters
      end

      def draw_graphs
        Gosu.draw_path(@graphs[:frame_timings], Gosu::Color::WHITE, Float::INFINITY)
      end

      def draw_timings_and_counters
        frame = @frame_stats.last

        @data_label.text = "<c=f8f>COUNTERS:</c>\n#{frame.counters.map { |t, v| "#{t}: #{v}" }.join("\n")}\n\n"\
        "<c=f80>TIMINGS:</c>\n#{frame.attempted_multitiming? ? "<c=d00>Attempted Multitiming!\nTimings may be inaccurate for:\n#{frame.multitimings.map { |m, _| m}.join("\n") }</c>\n\n" : ''}#{frame.timings.map { |t, v| "#{t}: #{v.duration}ms" }.join("\n")}"
        Gosu.draw_rect(@data_label.x - @padding, @data_label.y - @padding, @data_label.width + @padding * 2, @data_label.height + @padding * 2, 0xdd_222222, @position.z)
        @data_label.draw

        # puts "Recalcs this frame: #{frame.counters[:gui_recalculations]} [dt: #{(CyberarmEngine::Window.dt * 1000).round} ms]" if frame.counters[:gui_recalculations] && frame.counters[:gui_recalculations].positive?
      end
    end
  end
end
