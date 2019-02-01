module CyberarmEngine
  class CheckBox < Button
    def initialize(options, block = nil)
      super(options[:checkmark], options, block)
      @checked = options[:checked] || false
      if @checked
        @text.text = options[:checkmark]
      else
        @text.text = ""
      end

      return self
    end

    def button_up(id)
      if mouse_over? && id == Gosu::MsLeft
        if @checked
          @checked = false
          @text.text = ""
        else
          @checked = true
          @text.text = @options[:checkmark]
        end

        @block.call(self) if @block
      end
    end

    def recalculate
      super

      @width = @text.textobject.text_width(@options[:checkmark])
    end

    def value
      @checked
    end
  end
end