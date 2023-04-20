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

      attr_reader :frame_timing, :counters, :timings
      def initialize
        @frame_timing = Timing.new(start_time: Gosu.milliseconds, end_time: -1, duration: -1)

        @counters = {
          gui_recalculations: 0
        }

        @timings = {}
      end

      def increment(key, number = 1)
        @counters[key] ||= 0
        @counters[key] += number
      end

      def start_timing(key)
        raise "key must be a symbol!" unless key.is_a?(Symbol)
        warn "Only one timing per key per frame. (Timing for #{key.inspect} already exists!)" if @timings[key]

        @timings[key] = Timing.new(start_time: Gosu.milliseconds, end_time: -1, duration: -1)
      end

      def end_timing(key)
        timing = @timings[key]

        warn "Timing #{key.inspect} already ended!" if timing.end_time != -1

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
      end

      def complete?
        @frame_timing.duration != -1
      end
    end
  end
end
