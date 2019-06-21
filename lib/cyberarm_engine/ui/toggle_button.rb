module CyberarmEngine
  class ToggleButton < Button
    attr_reader :toggled

    def initialize(options, block = nil)
      super(options[:checkmark], options, block)
      @toggled = options[:toggled] || false
      if @toggled
        @text.text = @options[:checkmark]
      else
        @text.text = ""
      end

      return self
    end

    def toggled=(boolean)
      @toggled = !boolean
      toggle
    end

    def clicked_left_mouse_button(sender, x, y)
      toggle

      @block.call(self) if @block
    end

    def toggle
      if @toggled
        @toggled = false
        @text.text = ""
      else
        @toggled = true
        @text.text = @options[:checkmark]
      end
    end

    def recalculate
      super

      @style.width = @text.textobject.text_width(@options[:checkmark])
      update_background
    end

    def value
      @toggled
    end
  end
end