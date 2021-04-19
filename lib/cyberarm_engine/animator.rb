module CyberarmEngine
  class Animator
    def initialize(start_time:, duration:, from:, to:, tween: :linear, &block)
      @start_time = start_time
      @duration = duration
      @from = from.dup
      @to = to.dup
      @tween = tween
      @block = block
    end

    def update
      @block.call(self, @from, @to) if @block
    end

    def progress
      ((Gosu.milliseconds - @start_time) / @duration.to_f).clamp(0.0, 1.0)
    end

    def complete?
      progress >= 1.0
    end

    def transition(from = @from, to = @to, tween = @tween)
      from + (to - from) * send("tween_#{tween}", progress)
    end

    def color_transition(from = @from, to = @to, _tween = @tween)
      r = transition(from.red, to.red)
      g = transition(from.green, to.green)
      b = transition(from.blue, to.blue)
      a = transition(from.alpha, to.alpha)

      Gosu::Color.rgba(r, g, b, a)
    end

    def color_hsv_transition(from = @from, to = @to, tween = @tween)
      hue = transition(from.hue, to.hue, tween)
      saturation = transition(from.saturation, to.saturation, tween)
      value = transition(from.value, to.value, tween)
      alpha = transition(from.alpha, to.alpha, tween)

      Gosu::Color.from_ahsv(alpha, hue, saturation, value)
    end

    # NOTE: Use this for future reference? https://github.com/danro/easing-js/blob/master/easing.js

    def tween_linear(t)
      t
    end

    def tween_ease_in_out(t)
      (-0.5 * (Math.cos(Math::PI * t) - 1))
    end
  end
end
