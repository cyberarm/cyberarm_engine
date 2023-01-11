module CyberarmEngine
  class Element
    class Progress < Element
      attr_reader :type

      def initialize(options = {}, block = nil)
        super(options, block)

        @animation_speed = options[:animation_speed] || 3_000
        @marquee_width = options[:marquee_width] || 0.25
        @marquee_offset = 0
        @marquee_animation_time = Gosu.milliseconds
        @type = options[:type] || :linear
        @fraction_background = Background.new(background: @style.fraction_background)
        self.value = options[:fraction] || 0.0
      end

      def render
        @fraction_background.draw
      end

      def recalculate
        _width = dimensional_size(@style.width, :width)
        _height = dimensional_size(@style.height, :height)
        @width = _width
        @height = _height

        update_background
      end

      def update_background
        super

        @fraction_background.x = (@style.border_thickness_left + @style.padding_left + @x) + @marquee_offset
        @fraction_background.y = @style.border_thickness_top + @style.padding_top + @y
        @fraction_background.z = @z
        @fraction_background.width = @width * (@type == :marquee ? @marquee_width : @fraction)
        @fraction_background.height = @height

        @fraction_background.background = @style.fraction_background
      end

      def update
        super

        return unless @type == :marquee

        marquee_width = @width * @marquee_width
        range = @width + marquee_width

        @marquee_offset = (@width * (Gosu.milliseconds - @marquee_animation_time) / @animation_speed) - marquee_width
        @marquee_animation_time = Gosu.milliseconds if @marquee_offset > range

        update_background
        root.gui_state.request_repaint
      end

      def type=(type)
        @type = type

        case type
        when :linear
          @marquee_offset = 0
        when :marquee
          @marquee_offset = 0
          @marquee_animation_time = Gosu.milliseconds
        else
          raise ArgumentError, "Only types :linear and :marquee are supported"
        end

        update_background
      end

      def value
        @fraction
      end

      def value=(decimal)
        raise "value must be number" unless decimal.is_a?(Numeric)

        old_value = @fraction

        @fraction = decimal.clamp(0.0, 1.0)
        update_background

        root.gui_state.request_repaint if @fraction != old_value

        publish(:changed, @fraction)
        @fraction
      end
    end
  end
end
