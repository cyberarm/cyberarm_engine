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

        @max_timing_label = CyberarmEngine::Text.new("", x: x + @padding + 1, y: y + @padding, z: z, size: @text_size, border: true)
        @avg_timing_label = CyberarmEngine::Text.new("", x: x + @padding + 1, y: y + @padding + @height / 2 - @text_size / 2, z: z, size: @text_size, border: true)
        @min_timing_label = CyberarmEngine::Text.new("", x: x + @padding + 1, y: y + @height - (@text_size + @padding / 2), z: z, size: @text_size, border: true)

        @timings_label = CyberarmEngine::Text.new("", x: x + @padding + @width + @padding, y: y + @padding, z: z, size: @text_size, border: true)

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

        nodes.each_with_index do |cluster, i|
          break if cluster.empty?

          @graphs[:frame_timings] << CyberarmEngine::Vector.new(@position.x + @padding + 1 * i, (@position.y + @height - @padding) - cluster.max)
        end
      end

      def draw
        @frame_stats = CyberarmEngine::Stats.frames.select(&:complete?)
        return if @frame_stats.empty?

        calculate_graphs

        @max_timing_label.text = "Max: #{@frame_stats.map { |f| f.frame_timing.duration }.max.to_s.rjust(3, " ")}ms"
        @avg_timing_label.text = "Avg: #{(@frame_stats.map { |f| f.frame_timing.duration }.sum / @frame_stats.size).to_s.rjust(3, " ")}ms"
        @min_timing_label.text = "Min: #{@frame_stats.map { |f| f.frame_timing.duration }.min.to_s.rjust(3, " ")}ms"

        Gosu.draw_rect(@position.x, @position.y, @width, @height, 0xaa_222222, @position.z)
        Gosu.draw_rect(@position.x + @padding, @position.y + @padding, @width - @padding * 2, @height - @padding * 2, 0xaa_222222, @position.z)

        draw_graphs

        @max_timing_label.draw
        @avg_timing_label.draw
        @min_timing_label.draw

        # TODO: Make this optional
        draw_timings
      end

      def draw_graphs
        Gosu.draw_path(@graphs[:frame_timings], Gosu::Color::WHITE, Float::INFINITY)
      end

      def draw_timings
        frame = @frame_stats.last

        @timings_label.text = "#{frame.attempted_multitiming? ? "<c=d00>Attempted Multitiming!\nTimings may be inaccurate for:\n#{frame.multitimings.map { |m, _| m}.join("\n") }</c>\n\n" : ''}#{frame.timings.map { |t, v| "#{t}: #{v.duration}ms" }.join("\n")}"
        Gosu.draw_rect(@timings_label.x - @padding, @timings_label.y - @padding, @timings_label.width + @padding * 2, @timings_label.height + @padding * 2, 0xdd_222222, @position.z)
        @timings_label.draw
      end
    end
  end
end
