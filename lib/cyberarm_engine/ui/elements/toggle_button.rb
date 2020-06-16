module CyberarmEngine
  class Element
    class ToggleButton < Button
      attr_reader :toggled

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
          @text.text = @options[:checkmark]
        else
          @image = nil
          @text.text = ""
        end

        return self
      end

      def clicked_left_mouse_button(sender, x, y)
        self.value = !@value

        @block.call(self) if @block

        return :handled
      end

      def recalculate
        if @image
          super
        else
          super

          _width = dimensional_size(@style.width, :width)
          _height= dimensional_size(@style.height,:height)

          @width  = _width  ? _width  : @text.textobject.text_width(@options[:checkmark])
          @height = _height ? _height : @text.height

          update_background
        end
      end

      def value
        @value
      end

      def value=(boolean)
        @value = boolean

        if boolean
          @image = @_image if @_image
          @text.text = @options[:checkmark]
        else
          @image = nil
          @text.text = ""
        end

        recalculate

        publish(:changed, @value)
      end
    end
  end
end