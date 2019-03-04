module CyberarmEngine
  class Image < Element
    def initialize(path, options = {}, block = nil)
      super(options, block)
      @path = path

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

    def render
      @image.draw(@x + @padding_left, @y + @padding_top, @z + 2, @scale_x, @scale_y) # TODO: Add color support?
    end

    def clicked_left_mouse_button(sender, x, y)
      @block.call(self) if @block
    end

    def recalculate
      @width  = @image.width * @scale_x
      @height = @image.height * @scale_y
    end

    def value
      @path
    end
  end
end