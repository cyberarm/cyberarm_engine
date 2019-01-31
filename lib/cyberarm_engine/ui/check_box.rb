module CyberarmEngine
  class CheckBox < Element
    def initialize(options, block = nil)
      super(options, block)
      @checked = options[:checked] || false

      @text = Text.new("X", font: @options[:font], color: @options[:interactive_stroke], size: @options[:text_size], shadow: @options[:text_shadow])

      return self
    end

    def draw
      $window.draw_rect(@x, @y, width, height, @options[:background], @z+1)

      if mouse_over?
        $window.draw_rect(@x+1, @y+1, width-2, height-2, @options[:interactive_hover_background], @z+2)
      else
        if @checked
          $window.draw_rect(@x+1, @y+1, width-2, height-2, @options[:interactive_active_background], @z+2)
        else
          $window.draw_rect(@x+1, @y+1, width-2, height-2, @options[:interactive_background], @z + 2)
        end
      end

      @text.draw if @checked
    end

    def button_up(id)
      if mouse_over? && id == Gosu::MsLeft
        if @checked
          @checked = false
        else
          @checked = true
        end

        @block.call(self) if @block
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
      @checked
    end
  end
end