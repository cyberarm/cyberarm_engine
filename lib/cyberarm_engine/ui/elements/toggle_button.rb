module CyberarmEngine
  class Element
    class ToggleButton < Button
      attr_reader :toggled, :value

      def initialize(options, block = nil)
        if options.dig(:theme, :ToggleButton, :checkmark_image)
          options[:theme][:ToggleButton][:image_width] ||= options[:theme][:Label][:text_size]
          super(get_image(options.dig(:theme, :ToggleButton, :checkmark_image)), options, block)

          @_image = @image
        else
          super(options[:checkmark], options, block)
        end

        @value = options[:checked] || false

        if @value
          @image = @_image if @_image
          @raw_text = @options[:checkmark]
        else
          @image = nil
          @raw_text = ""
        end
      end

      def clicked_left_mouse_button(_sender, _x, _y)
        self.value = !@value

        @block.call(self) if @block

        :handled
      end

      def recalculate
        super
        return if @image

        _width  = dimensional_size(@style.width,  :width)
        _height = dimensional_size(@style.height, :height)

        @width  = _width  || @text.textobject.text_width(@options[:checkmark])
        @height = _height || @text.height

        update_background
      end

      def value=(boolean)
        @value = boolean

        if boolean
          @image = @_image if @_image
          @raw_text = @options[:checkmark]
        else
          @image = nil
          @raw_text = ""
        end

        recalculate

        publish(:changed, @value)
      end
    end
  end
end
