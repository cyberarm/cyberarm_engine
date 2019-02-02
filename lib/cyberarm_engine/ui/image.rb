module CyberarmEngine
  class Image < Element
    def initialize(path, options = {}, block = nil)
      super(options, block)

      @image = Gosu::Image.new(path, retro: @options[:image_retro])
      if @options[:width].nonzero? && @options[:height].nonzero?
        @scale_x = @options[:width].to_f / @image.width
        @scale_y = @options[:height].to_f / @image.height
      elsif @options[:width].nonzero?
        @scale_x = @options[:width].to_f / @image.width
        @scale_y = @scale_x
      elsif @options[:height].nonzero?
        @scale_y = @options[:height].to_f / @image.height
        @scale_x = @scale_y
      else
        @scale_x, @scale_y = 1, 1
      end

      raise "Scale X" unless @scale_x.is_a?(Numeric)
      raise "Scale Y" unless @scale_y.is_a?(Numeric)
    end

    def draw
      $window.draw_rect(relative_x, relative_y, width, height, @options[:fill], @z+1)

      @image.draw(relative_x + @padding, relative_y + @padding, @z + 2, @scale_x, @scale_y) # TODO: Add color support?
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
      @width  = @image.width * @scale_x
      @height = @image.height * @scale_y
    end
  end
end