module CyberarmEngine
  class Button < Label
    def draw
      draw_text
      draw_button
    end

    def draw_text
      @text.draw
    end

    def mouse_over?; false; end

    def draw_button
      $window.draw_rect(relative_x, relative_y, width, height, @options[:element_background], @z+1)

      if mouse_over? && $window.button_down?(Gosu::MsLeft)
        $window.draw_rect(
          relative_x + @options[:interactive_border_size],
          relative_y + @options[:interactive_border_size],
          width - (@options[:interactive_border_size]*2),
          height- (@options[:interactive_border_size]*2),
          @options[:interactive_active_background],
          @z+2
        )

        @text.color = @options[:interactive_active_stroke]
      elsif mouse_over?
        $window.draw_rect(
          relative_x + @options[:interactive_border_size],
          relative_y + @options[:interactive_border_size],
          width - (@options[:interactive_border_size]*2),
          height- (@options[:interactive_border_size]*2),
          @options[:interactive_hover_background],
          @z+2
        )
        # show_tooltip
        @text.color = @options[:interactive_stroke]
      else
        $window.draw_rect(
          relative_x + @options[:interactive_border_size],
          relative_y + @options[:interactive_border_size],
          width - (@options[:interactive_border_size]*2),
          height- (@options[:interactive_border_size]*2),
          @options[:interactive_background],
          @z+2
        )

        @text.color = @options[:interactive_stroke]
      end
    end
  end
end