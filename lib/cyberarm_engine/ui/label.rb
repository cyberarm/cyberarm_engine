module CyberarmEngine
  class Label < Element
    def initialize(text, options = {}, block = nil)
      super(options, block)

      @text = Text.new(text, font: @options[:font], z: @z, color: @options[:color], size: @options[:text_size], shadow: @options[:text_shadow])

      return self
    end

    def render
      @text.draw
    end

    def clicked_left_mouse_button(sender, x, y)
      @block.call(self) if @block
    end

    def recalculate
      unless @visible
        @width = 0
        @height= 0
        return
      end

      @width = @text.width.round
      @height= @text.height.round

      @text.x = @border_thickness_left + @padding_left + @x
      @text.y = @border_thickness_top + @padding_top  + @y
      @text.z = @z + 3

      update_background
    end

    def value
      @text.text
    end

    def value=(value)
      @text.text = value

      old_width, old_height = width, height
      recalculate

      root.recalculate if old_width != width || old_height != height
    end
  end
end