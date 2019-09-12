module CyberarmEngine
  class Element
    class Button < Label
      def initialize(text, options = {}, block = nil)
        super(text, options, block)

        @style.background_canvas.background = default(:background)
      end

      def render
        draw_text
      end

      def draw_text
        @text.draw
      end

      def enter(sender)
        @focus = false unless window.button_down?(Gosu::MsLeft)

        if @focus
          @style.background_canvas.background = default(:active, :background)
          @text.color = default(:active, :color)
        else
          @style.background_canvas.background = default(:hover, :background)
          @text.color = default(:hover, :color)
        end

        return :handled
      end

      def left_mouse_button(sender, x, y)
        @focus = true
        @style.background_canvas.background = default(:active, :background)
        window.current_state.focus = self
        @text.color = default(:active, :color)

        return :handled
      end

      def released_left_mouse_button(sender,x, y)
        enter(sender)

        return :handled
      end

      def clicked_left_mouse_button(sender, x, y)
        @block.call(self) if @block

        return :handled
      end

      def leave(sender)
        @style.background_canvas.background = default(:background)
        @text.color = default(:color)

        return :handled
      end

      def blur(sender)
        @focus = false

        return :handled
      end
    end
  end
end