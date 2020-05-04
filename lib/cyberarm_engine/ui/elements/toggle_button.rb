module CyberarmEngine
  class Element
    class ToggleButton < Button
      attr_reader :toggled

      def initialize(options, block = nil)
        super(options[:checkmark], options, block)
        @value = options[:checked] || false
        if @value
          @text.text = @options[:checkmark]
        else
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
        super

        _width = dimensional_size(@style.width, :width)
        _height= dimensional_size(@style.height,:height)

        @width  = _width  ? _width  : @text.textobject.text_width(@options[:checkmark])
        @height = _height ? _height : @text.height

        update_background
      end

      def value
        @value
      end

      def value=(boolean)
        @value = boolean

        if boolean
          @text.text = @options[:checkmark]
        else
          @text.text = ""
        end

        recalculate

        publish(:changed, @value)
      end
    end
  end
end