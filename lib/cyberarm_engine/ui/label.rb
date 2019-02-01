module CyberarmEngine
  class Label < Element
    def initialize(text, options = {}, block = nil)
      super(options, block)

      @text = Text.new(text, font: @options[:font], z: @z, color: @options[:stroke], size: @options[:text_size], shadow: @options[:text_shadow])

      return self
    end

    def draw
      $window.draw_rect(relative_x, relative_y, width, height, @options[:fill], @z+1)

      @text.draw
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

      @text.x = relative_x + @padding
      @text.y = relative_y + @padding
      @text.z = @z + 3
    end

    def value
      @text.text
    end
  end
end