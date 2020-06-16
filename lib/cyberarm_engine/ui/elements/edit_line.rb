module CyberarmEngine
  class Element
    class EditLine < Button
      def initialize(text, options = {}, block = nil)
        super(text, options, block)

        @type = default(:type)

        @caret_width = default(:caret_width)
        @caret_height= @text.textobject.height
        @caret_color = default(:caret_color)
        @caret_interval = default(:caret_interval)
        @caret_last_interval = Gosu.milliseconds
        @show_caret  = true

        @text_input = Gosu::TextInput.new
        @text_input.text = text
        @last_text_value = text

        @offset_x, @offset_y = 0, 0

        event(:begin_drag)
        event(:drag_update)
        event(:end_drag)
      end

      def render
        Gosu.clip_to(@text.x, @text.y, @width, @height) do
          Gosu.translate(-@offset_x, -@offset_y) do
            draw_selection
            draw_caret if @focus && @show_caret
            draw_text
          end
        end
      end

      def draw_text
        @text.draw(:draw_text)
      end

      def draw_caret
        Gosu.draw_rect(caret_position, @text.y, @caret_width, @caret_height, @caret_color, @z)
      end

      def draw_selection
        selection_width = caret_position - selection_start_position

        Gosu.draw_rect(selection_start_position, @text.y, selection_width, @text.height, default(:selection_color), @z)
      end

      def update
        if @type == :password
          @text.text = default(:password_character) * @text_input.text.length
        else
          @text.text = @text_input.text
        end

        if @last_text_value != self.value
          @last_text_value = self.value

          publish(:changed, self.value)
        end

        if Gosu.milliseconds >= @caret_last_interval + @caret_interval
          @caret_last_interval = Gosu.milliseconds

          @show_caret = !@show_caret
        end

        keep_caret_visible
      end

      def button_down(id)
        handle_keyboard_shortcuts(id)
      end

      def handle_keyboard_shortcuts(id)
        return unless @focus && @enabled
        if Gosu.button_down?(Gosu::KB_LEFT_CONTROL) or Gosu.button_down?(Gosu::KB_RIGHT_CONTROL)
          case id
          when Gosu::KB_A
            @text_input.selection_start = 0
            @text_input.caret_pos = @text_input.text.length

          when Gosu::KB_C
            if @text_input.selection_start < @text_input.caret_pos
              Clipboard.copy(@text_input.text[@text_input.selection_start...@text_input.caret_pos])
            else
              Clipboard.copy(@text_input.text[@text_input.caret_pos...@text_input.selection_start])
            end

          when Gosu::KB_X
            chars = @text_input.text.chars

            if @text_input.selection_start < @text_input.caret_pos
              Clipboard.copy(@text_input.text[@text_input.selection_start...@text_input.caret_pos])
              chars.slice!(@text_input.selection_start, @text_input.caret_pos)
            else
              Clipboard.copy(@text_input.text[@text_input.caret_pos...@text_input.selection_start])
              chars.slice!(@text_input.caret_pos, @text_input.selection_start)
            end

            @text_input.text = chars.join

          when Gosu::KB_V
            if instance_of?(EditLine) # EditLine assumes a single line of text
              @text_input.text = @text_input.text.insert(@text_input.caret_pos, Clipboard.paste.encode("UTF-8").gsub("\n", ""))
            else
              @text_input.text = @text_input.text.insert(@text_input.caret_pos, Clipboard.paste.encode("UTF-8"))
            end
          end
        end
      end

      def caret_position_under_mouse(mouse_x)
        1.upto(@text.text.length) do |i|
          if mouse_x < @text.x - @offset_x + @text.width(@text.text[0...i])
            return i - 1
          end
        end

        @text_input.text.length
      end

      def move_caret_to_mouse(mouse_x, mouse_y)
        @text_input.caret_pos = @text_input.selection_start = caret_position_under_mouse(mouse_x)
      end

      def keep_caret_visible
        caret_pos = (caret_position - @text.x) + @caret_width

        @last_text ||= "/\\"
        @last_pos ||= -1

        @last_text = @text.text
        @last_pos = caret_pos


        if caret_pos.between?(@offset_x, @width + @offset_x)
          # Do nothing

        elsif caret_pos < @offset_x
          if caret_pos > @width
            @offset_x = caret_pos + @width
          else
            @offset_x = 0
          end

        elsif caret_pos > @width
          @offset_x = caret_pos - @width

        else
          # Reset to Zero
          @offset_x = 0
        end
      end

      def caret_position
        text_input_position_for(:caret_pos)
      end

      def selection_start_position
        text_input_position_for(:selection_start)
      end

      def text_input_position_for(method)
        if @type == :password
          @text.x + @text.width(default(:password_character) * @text_input.text[0...@text_input.send(method)].length)
        else
          @text.x + @text.width(@text_input.text[0...@text_input.send(method)])
        end
      end

      def left_mouse_button(sender, x, y)
        super
        window.text_input = @text_input

        @caret_last_interval = Gosu.milliseconds
        @show_caret = true

        move_caret_to_mouse(x, y)

        return :handled
      end

      def enter(sender)
        if @focus
          @style.background_canvas.background = default(:active, :background)
          @text.color = default(:active, :color)
        else
          @style.background_canvas.background = default(:hover, :background)
          @text.color = default(:hover, :color)
        end

        return :handled
      end

      def leave(sender)
        unless @focus
          super
        end

        return :handled
      end

      def blur(sender)
        @focus = false
        @style.background_canvas.background = default(:background)
        @text.color = default(:color)
        window.text_input = nil

        return :handled
      end

      def draggable?(button)
        button == :left
      end

      def begin_drag(sender, x, y, button)
        @drag_start = x
        @offset_drag_start = @offset_x
        @drag_caret_position = @text_input.caret_pos

        :handled
      end

      def drag_update(sender, x, y, button)
        @text_input.caret_pos = caret_position_under_mouse(x)

        :handled
      end

      def end_drag(sender, x, y, button)

        :handled
      end

      def recalculate
        super

        @width = dimensional_size(@style.width, :width) || default(:width)
        update_background
      end

      def value
        @text_input.text
      end
    end
  end
end