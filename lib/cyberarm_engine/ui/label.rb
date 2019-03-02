module CyberarmEngine
  class Label < Element
    def initialize(text, options = {}, block = nil)
      super(options, block)

      @text = Text.new(text, font: @options[:font], z: @z, color: @options[:stroke], size: @options[:text_size], shadow: @options[:text_shadow])

      return self
    end

    def draw
      $window.draw_rect(@x, @y, width, height, @options[:fill], @z+1)

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

      @text.x = @padding_left + @x
      @text.y = @padding_top  + @y
      @text.z = @z + 3
    end

    def value
      @text.text
    end
  end
end