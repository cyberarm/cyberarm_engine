module CyberarmEngine
  class Animator
    DEFAULT_TWEEN = :linear
    def initialize(start_time:, duration:, &block)
      @start_time, @duration = start_time, duration
      @block = block
    end

    def update
      @block.call(self) if @block
    end

    def progress
      (@start_time.to_f + (Gosu.milliseconds - @start_time)) / (@start_time + @duration.to_f)
    end

    def complete?
      progress >= 1.0
    end

    def transition(from, to, tween = DEFAULT_TWEEN)
      from + (to - from) * send("tween_#{tween}", progress)
    end

    def color_transition(from, to, tween = DEFAULT_TWEEN)
      r = transition(from.red, to.red)
      g = transition(from.green, to.green)
      b = transition(from.blue, to.blue)
      a = transition(from.alpha, to.alpha)

      Gosu::Color.rgba(r, g, b, a)
    end

    def color_hsv_transition(from, to, tween = DEFAULT_TWEEN)
      hue = transition(from.hue, to.hue, tween)
      saturation = transition(from.saturation, to.saturation, tween)
      value = transition(from.value, to.value, tween)
      alpha = transition(from.alpha, to.alpha, tween)

      Gosu::Color.from_ahsv(alpha, hue, saturation, value)
    end

    # NOTE: maybe use this for future reference? https://github.com/danro/easing-js/blob/master/easing.js

    def tween_linear(t)
      t
    end

    def tween_sine(t)
      Math.sin(t) * t
    end
  end
end