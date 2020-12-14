module CyberarmEngine
  class Timer
    def initialize(interval, looping = true, &block)
      @interval = interval
      @looping = looping
      @block = block

      @last_interval = Gosu.milliseconds
      @triggered = false
    end

    def update
      return if !@looping && @triggered

      if Gosu.milliseconds >= @last_interval + @interval
        @last_interval = Gosu.milliseconds
        @triggered = true

        @block.call if @block
      end
    end
  end
end
