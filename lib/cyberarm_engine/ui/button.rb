module CyberarmEngine
  class Button < Label
    def initialize(text, options = {}, block = nil)
      super(text, options, block)

      @background_canvas.background = @options[:interactive_background]
    end

    def render
      draw_text
    end

    def draw_text
      @text.draw
    end

    def enter(sender)
      @background_canvas.background = @options[:interactive_hover_background]
      @text.color = @options[:interactive_stroke]
    end

    def left_mouse_button(sender, x, y)
      @background_canvas.background = @options[:interactive_active_background]
      @text.color = @options[:interactive_active_stroke]
    end

    def released_left_mouse_button(sender,x, y)
      enter(sender)
    end

    def leave(sender)
      @background_canvas.background = @options[:interactive_background]
      @text.color = @options[:interactive_stroke]
    end

    def clicked_left_mouse_button(sender, x, y)
      @block.call(self) if @block
    end
  end
end