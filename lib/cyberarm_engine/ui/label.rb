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
      @style.width = @text.width.round
      @style.height= @text.height.round

      @text.x = @style.border_thickness_left + @style.padding_left + @x
      @text.y = @style.border_thickness_top + @style.padding_top  + @y
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

      root.gui_state.request_recalculate if old_width != width || old_height != height
    end
  end
end