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
      @background_canvas.background = default(:hover, :background)
      @text.color = default(:hover, :color)
    end

    def left_mouse_button(sender, x, y)
      @background_canvas.background = default(:active, :background)
      @text.color = default(:active, :color)
    end

    def released_left_mouse_button(sender,x, y)
      enter(sender)
    end

    def leave(sender)
      @background_canvas.background = default(:background)
      @text.color = default(:color)
    end

    def clicked_left_mouse_button(sender, x, y)
      @block.call(self) if @block
    end
  end
end