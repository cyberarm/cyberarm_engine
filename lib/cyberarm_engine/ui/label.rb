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

    def recalculate
      @width = @text.width
      @height= @text.height

      @text.x = @x + @padding
      @text.y = @y + @padding
      @text.z = @z + 3
    end
  end
end