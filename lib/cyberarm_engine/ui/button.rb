module CyberarmEngine
  class Button < Label
    def draw
      draw_text
      draw_button
    end

    def draw_text
      @text.draw
    end

    def enter(sender)
      @background = @options[:interactive_hover_background]
      @text.color = @options[:interactive_stroke]
    end

    def holding_left_mouse_button(sender, x, y)
      @background = @options[:interactive_active_background]
      @text.color = @options[:interactive_active_stroke]
    end

    def released_left_mouse_button(sender,x, y)
      enter(sender)
    end

    def leave(sender)
      @background = @options[:interactive_background]
      @text.color = @options[:interactive_stroke]
    end

    def clicked_left_mouse_button(sender, x, y)
      @block.call(self) if @block
    end

    def draw_button
      $window.draw_rect(@x, @y, width, height, @options[:element_background], @z+1)

      @background ||= @options[:interactive_background]
      $window.draw_rect(
        @x + @options[:interactive_border_size],
        @y + @options[:interactive_border_size],
        width - (@options[:interactive_border_size]*2),
        height- (@options[:interactive_border_size]*2),
        @background,
        @z+2
      )
    end
  end
end