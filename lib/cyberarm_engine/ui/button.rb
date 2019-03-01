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
      @text.color = @options[:interactive_active_stroke]
    end

    def leave(sender)
      @background = @options[:interactive_background]
      @text.color = @options[:interactive_stroke]
    end

    def clicked_left_mouse_button(sender, x, y)
      @block.call if block
    end

    def draw_button
      $window.draw_rect(relative_x, relative_y, width, height, @options[:element_background], @z+1)

      @background ||= @options[:interactive_background]
      $window.draw_rect(
        relative_x + @options[:interactive_border_size],
        relative_y + @options[:interactive_border_size],
        width - (@options[:interactive_border_size]*2),
        height- (@options[:interactive_border_size]*2),
        @background,
        @z+2
      )
    end
  end
end