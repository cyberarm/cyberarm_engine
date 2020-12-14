module CyberarmEngine
  class Element
    class Progress < Element
      def initialize(options = {}, block = nil)
        super(options, block)

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

        @fraction_background.x = @style.border_thickness_left + @style.padding_left + @x
        @fraction_background.y = @style.border_thickness_top + @style.padding_top + @y
        @fraction_background.z = @z
        @fraction_background.width = @width * @fraction
        @fraction_background.height = @height

        @fraction_background.background = @style.fraction_background
      end

      def value
        @fraction
      end

      def value=(decimal)
        raise "value must be number" unless decimal.is_a?(Numeric)

        @fraction = decimal.clamp(0.0, 1.0)
        update_background

        publish(:changed, @fraction)
        @fraction
      end
    end
  end
end
