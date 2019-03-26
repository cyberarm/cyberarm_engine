module CyberarmEngine
  class Button < Label
    def initialize(text, options = {}, block = nil)
      super(text, options, block)

      @background_canvas.background = default(:background)
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
        @background_canvas.background = default(:active, :background)
        @text.color = default(:active, :color)
      else
        @background_canvas.background = default(:hover, :background)
        @text.color = default(:hover, :color)
      end
    end

    def left_mouse_button(sender, x, y)
      @focus = true
      @background_canvas.background = default(:active, :background)
      window.current_state.focus = self
      @text.color = default(:active, :color)
    end

    def released_left_mouse_button(sender,x, y)
      enter(sender)
    end

    def clicked_left_mouse_button(sender, x, y)
      @block.call(self) if @block
    end

    def leave(sender)
      @background_canvas.background = default(:background)
      @text.color = default(:color)
    end

    def blur(sender)
      @focus = false
    end
  end
end