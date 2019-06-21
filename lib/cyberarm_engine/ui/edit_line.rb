module CyberarmEngine
  class EditLine < Button
    def initialize(text, options = {}, block = nil)
      super(text, options, block)

      @type = default(:type)

      @caret_width = default(:caret_width)
      @caret_height= @text.height
      @caret_color = default(:caret_color)
      @caret_interval = default(:caret_interval)
      @caret_last_interval = Gosu.milliseconds
      @show_caret  = true

      @text_input = Gosu::TextInput.new
      @text_input.text = text

      return self
    end

    def render
      Gosu.clip_to(@text.x, @text.y, @style.width, @text.height) do
        draw_text
        Gosu.draw_rect(caret_position, @text.y, @caret_width, @caret_height, @caret_color, @z + 40) if @focus && @show_caret
      end
    end

    def update
      if @type == :password
        @text.text = default(:password_character) * @text_input.text.length
      else
        @text.text = @text_input.text
      end

      if Gosu.milliseconds >= @caret_last_interval + @caret_interval
        @caret_last_interval = Gosu.milliseconds

        @show_caret = !@show_caret
      end
    end

    def left_mouse_button(sender, x, y)
      super
      window.text_input = @text_input
    end

    def enter(sender)
      if @focus
        @style.background_canvas.background = default(:active, :background)
        @text.color = default(:active, :color)
      else
        @style.background_canvas.background = default(:hover, :background)
        @text.color = default(:hover, :color)
      end
    end

    def leave(sender)
      unless @focus
        super
      end
    end

    def blur(sender)
      @focus = false
      @style.background_canvas.background = default(:background)
      @text.color = default(:color)
      window.text_input = nil
    end

    # TODO: Fix caret rendering in wrong position unless caret_pos is at end of text
    def caret_position
      if @type == :password
        @text.x + @text.textobject.text_width(default(:password_character) * @text_input.text[0..@text_input.caret_pos-1].length)
      else
        @text.x + @text.textobject.text_width(@text_input.text[0..@text_input.caret_pos-1])
      end
    end

    def recalculate
      super

      @style.width = default(:width)
      update_background
    end

    def value
      @text_input.text
    end
  end
end