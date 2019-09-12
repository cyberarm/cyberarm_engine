module CyberarmEngine
  class Element
    class Label < Element
      def initialize(text, options = {}, block = nil)
        super(options, block)

        @text = Text.new(text, font: @options[:font], z: @z, color: @options[:color], size: @options[:text_size], shadow: @options[:text_shadow])
      end

      def render
        @text.draw
      end

      def clicked_left_mouse_button(sender, x, y)
        @block.call(self) if @block

        return :handled
      end

      def recalculate
        _width = dimensional_size(@style.width, :width)
        _height= dimensional_size(@style.height,:height)
        @width = _width  ? _width  : @text.width.round
        @height= _height ? _height : @text.height.round

        @text.x = @style.border_thickness_left + @style.padding_left + @x
        @text.y = @style.border_thickness_top + @style.padding_top  + @y
        @text.z = @z + 3

        update_background
      end

      def value
        @text.text
      end

      def value=(value)
        @text.text = value

        old_width, old_height = width, height
        recalculate

        root.gui_state.request_recalculate if old_width != width || old_height != height
      end
    end
  end
end