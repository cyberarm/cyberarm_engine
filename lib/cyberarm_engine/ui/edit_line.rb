module CyberarmEngine
  class EditLine < Button
    def initialize(text, options = {}, block = nil)
      super(text, options, block)

      @type = @options[:type] || :plain


      @caret_width = @options[:caret_width]
      @caret_height= @text.height
      @caret_color = @options[:caret_color]
      @caret_interval = @options[:caret_interval]
      @caret_last_interval = Gosu.milliseconds
      @show_caret  = true

      @text_input = Gosu::TextInput.new
      @text_input.text = text

      return self
    end

    def draw
      Gosu.clip_to(@x, @y, width, height) do
        draw_text
        Gosu.draw_rect(caret_position, @text.y, @caret_width, @caret_height, @caret_color, @z + 40) if @show_caret
      end

      draw_button
    end

    def update
      if @type == :password
        @text.text = @options[:edit_line_password_character] * @text_input.text.length
      else
        @text.text = @text_input.text
      end

      if Gosu.milliseconds >= @caret_last_interval + @caret_interval
        @caret_last_interval = Gosu.milliseconds

        @show_caret = !@show_caret
      end
    end

    def button_up(id)
      case id
      when Gosu::MsLeft
        if mouse_over?
          @focus = !@focus

          if @focus
            $window.text_input = @text_input
          else
            $window.text_input = nil
          end
          @block.call(self) if @block
        end
      end
    end

    def clicked_left_mouse_button(sender, x, y)
      window.current_state.focus=self
      window.text_input = @text_input
      @block.call(self) if @block
    end

    def blur(sender)
      window.text_input = nil
    end

    def caret_position
      if $window.text_input && $window.text_input == @text_input
        if @type == :password
          @text.x + @text.textobject.text_width(@options[:edit_line_password_character] * @text_input.text[0..@text_input.caret_pos].length)
        else
          @text.x + @text.textobject.text_width(@text_input.text[0..@text_input.caret_pos])
        end
      else
        0
      end
    end

    def recalculate
      super

      @width = @options[:edit_line_width]
    end

    def value
      @text_input.text
    end
  end
end