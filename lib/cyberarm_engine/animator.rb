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

    # Tween functions based on those provided here: https://github.com/danro/easing-js/blob/master/easing.js
    # Under MIT / BSD

    def tween_linear(t)
      t
    end

    def tween_ease_in_quad(t)
      t ** 2
    end

    def tween_ease_out_quad(t)
      -((t - 1) ** 2) -1
    end

    def tween_ease_in_out_quad(t)
      return 0.5 * (t ** 2) if (t /= 0.5) < 1
      return -0.5 * ((t -= 2) * t - 2)
    end

    def tween_ease_in_cubic(t)
      t ** 3
    end

    def tween_ease_out_cubic(t)
      ((t - 1) ** 3) + 1
    end

    def tween_ease_in_out_cubic(t)
      return 0.5 * (t ** 3) if ((t /= 0.5) < 1)
      return 0.5 * ((t - 2) ** 3) + 2
    end

    def tween_ease_in_quart(t)
      t ** 4
    end

    def tween_ease_out_quart(t)
      -((t - 1) ** 4) - 1
    end

    def tween_ease_in_out_quart(t)
      return 0.5 * (t ** 4) if ((t /= 0.5) < 1)
      return -0.5 * ((t -= 2) * (t ** 3) - 2)
    end

    def tween_ease_in_quint(t)
      t ** 5
    end

    def tween_ease_out_quint(t)
      ((t - 1) ** 5) + 1
    end

    def tween_ease_in_out_quint(t)
      return 0.5 * (t ** 5) if ((t /= 0.5) < 1)
      return 0.5 * ((t - 2) ** 5) + 2
    end

    def tween_ease_in(t) # sine
      -Math.cos(t * (Math::PI / 2)) + 1
    end

    def tween_ease_out(t) # sine
      Math.sin(t * (Math::PI / 2))
    end

    def tween_ease_in_out(t) # sine
      (-0.5 * (Math.cos(Math::PI * t) - 1))
    end

    def tween_ease_in_expo(t)
      (t == 0) ? 0 : 2 ** 10 * (t - 1)
    end

    def tween_ease_out_expo(t)
      (t == 1) ? 1 : -(2 ** -10 * t) + 1
    end

    def tween_ease_in_out_expo(t)
      return 0 if (t == 0)
      return 1 if (t == 1)
      return 0.5 * (2 ** 10 * (t - 1)) if ((t /= 0.5) < 1)
      return 0.5 * (-(2 ** -10 * (t -= 1)) + 2)
    end

    def tween_ease_in_circ(t)
      -(Math.sqrt(1 - (t * t)) - 1)
    end

    def tween_ease_out_circ(t)
      Math.sqrt(1 - ((t - 1) ** 2))
    end

    def tween_ease_in_out_circ(t)
      return -0.5 * (Math.sqrt(1 - t * t) - 1) if ((t /= 0.5) < 1)
      return 0.5 * (Math.sqrt(1 - (t -= 2) * t) + 1)
    end

    def tween_ease_in_back(t)
      s = 1.70158
      t * t * ((s + 1) * t - s)
    end

    def tween_ease_out_back(t)
      s = 1.70158
      (t = t - 1) * t * ((s + 1) * t + s) + 1
    end

    def tween_ease_in_out_back(t)
      s = 1.70158
      return 0.5 * (t * t * (((s *= (1.525)) + 1) * t - s)) if ((t /= 0.5) < 1)
      return 0.5 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2)
    end

    def tween_elastic(t)
      -1 * (4 ** (-8 * t)) * Math.sin((t * 6 - 1) * (2 * Math::PI) / 2) + 1
    end

    def tween_swing_from_to(t)
      s = 1.70158
      return 0.5 * (t * t * (((s *= (1.525)) + 1) * t - s)) if (t /= 0.5) < 1
      return 0.5 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2)
    end

    def tween_swing_from(t)
      s = 1.70158;
      t * t * ((s + 1) * t - s)
    end

    def tween_swing_to(t)
      s = 1.70158
      (t -= 1) * t * ((s + 1) * t + s) + 1
    end

    def tween_bounce(t)
      if (t < (1 / 2.75))
        (7.5625 * t * t)
      elsif (t < (2 / 2.75))
        (7.5625 * (t -= (1.5 / 2.75)) * t + 0.75)
      elsif (t < (2.5 / 2.75))
        (7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375)
      else
        (7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375)
      end
    end

    def tween_bounce_past(t)
      if (t < (1 / 2.75))
        # missing "2 -"?
        (7.5625 * t * t)
      elsif (t < (2 / 2.75))
        2 - (7.5625 * (t -= (1.5 / 2.75)) * t + 0.75)
      elsif (t < (2.5 / 2.75))
        2 - (7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375)
      else
        2 - (7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375)
      end
    end

    def tween_ease_from_to(t)
      return 0.5 * (t ** 4) if ((t /= 0.5) < 1)
      return -0.5 * ((t -= 2) * (t ** 3) - 2)
    end

    def tween_ease_from(t)
      t ** 4
    end

    def tween_ease_to(t)
      t ** 0.25
    end
  end
end
