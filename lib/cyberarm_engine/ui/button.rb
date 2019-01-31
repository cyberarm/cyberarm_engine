module CyberarmEngine
  class Button < Element
    def initialize(text, options = {}, block = nil)
      super(options, block)

      @text = Text.new(text, font: @options[:font], color: @options[:interactive_stroke], size: @options[:text_size], shadow: @options[:text_shadow])

      return self
    end

    def draw
      @text.draw

      $window.draw_rect(@x, @y, width, height, @options[:background], @z+1)

      if mouse_over? && $window.button_down?(Gosu::MsLeft)
        $window.draw_rect(@x+1, @y+1, width-2, height-2, @options[:interactive_active_background], @z+2)
      elsif mouse_over?
        $window.draw_rect(@x+1, @y+1, width-2, height-2, @options[:interactive_hover_background], @z+2)
        # show_tooltip
      else
        $window.draw_rect(@x+1, @y+1, width-2, height-2, @options[:interactive_background], @z+2)
      end
    end

    def button_up(id)
      case id
      when Gosu::MsLeft
        if mouse_over?
          @block.call(self) if @block
        end
      end
    end

    def recalculate
      @width = @text.width
      @height= @text.height

      @text.x = @x + @padding
      @text.y = @y + @padding
      @text.z = @z + 3
    end

    def value
      @text.text
    end
  end
end