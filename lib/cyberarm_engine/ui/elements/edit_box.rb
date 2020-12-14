module CyberarmEngine
  class Element
    class EditBox < EditLine
      def initialize(*args)
        super(*args)

        @active_line = 0

        @repeatable_keys = [
          {
            key: Gosu::KB_UP,
            down: false,
            repeat_delay: 50,
            last_repeat: 0,
            action: proc { move(:up) }
          },
          {
            key: Gosu::KB_DOWN,
            down: false,
            repeat_delay: 50,
            last_repeat: 0,
            action: proc { move(:down) }
          }
        ]
      end

      def update
        super

        caret_stay_left_of_last_newline
        calculate_active_line

        @repeatable_keys.each do |key|
          if key[:down] && (Gosu.milliseconds > key[:last_repeat] + key[:repeat_delay])
            key[:action].call
            key[:last_repeat] = Gosu.milliseconds
          end
        end
      end

      def draw_caret
        Gosu.draw_rect(caret_position, @text.y + @active_line * @text.textobject.height, @caret_width, @caret_height,
                       @caret_color, @z)
      end

      def draw_selection
        selection_width = caret_position - selection_start_position

        Gosu.draw_rect(selection_start_position, @text.y, selection_width, @text.textobject.height,
                       default(:selection_color), @z)
      end

      def text_input_position_for(_method)
        line = @text_input.text[0...@text_input.caret_pos].lines.last
        _x = @text.x + @offset_x

        if @type == :password
          _x + @text.width(default(:password_character) * line.length)
        else
          _x + @text.width(line)
        end
      end

      def set_position(int)
        int = 0 if int < 0
        @text_input.selection_start = @text_input.caret_pos = int
      end

      def calculate_active_line
        sub_text = @text_input.text[0...@text_input.caret_pos]
        @active_line = sub_text.lines.size - 1
      end

      def caret_stay_left_of_last_newline
        @text_input.text += "\n" unless @text_input.text.end_with?("\n")

        eof = @text_input.text.chomp.length
        set_position(eof) if @text_input.caret_pos > eof
      end

      def caret_position_under_mouse(mouse_x, mouse_y)
        active_line = row_at(mouse_y)
        right_offset = column_at(mouse_x, mouse_y)

        buffer = @text_input.text.lines[0..active_line].join if active_line != 0
        buffer = @text_input.text.lines.first if active_line == 0
        line = buffer.lines.last

        if buffer.chars.last == "\n"
          (buffer.length - line.length) + right_offset - 1
        else
          (buffer.length - line.length) + right_offset
        end
      end

      def move_caret_to_mouse(mouse_x, mouse_y)
        set_position(caret_position_under_mouse(mouse_x, mouse_y))
      end

      def row_at(y)
        ((y - @text.y) / @text.textobject.height).round
      end

      def column_at(x, y)
        row = row_at(y)

        buffer = @text_input.text.lines[0..row].join if row != 0
        buffer = @text_input.text.lines.first if row == 0

        line = @text_input.text.lines[row]
        line ||= ""
        column = 0

        line.length.times do |_i|
          break if @text.textobject.text_width(line[0...column]) >= (x - @text.x).clamp(0.0, Float::INFINITY)

          column += 1
        end

        column
      end

      def button_down(id)
        super

        @repeatable_keys.detect do |key|
          next unless key[:key] == id

          key[:down] = true
          key[:last_repeat] = Gosu.milliseconds + key[:repeat_delay]
          return true
        end

        case id
        when Gosu::KB_ENTER, Gosu::KB_RETURN
          caret_pos = @text_input.caret_pos
          @text_input.text = @text_input.text.insert(@text_input.caret_pos, "\n")
          @text_input.caret_pos = @text_input.selection_start = caret_pos + 1
        end
      end

      def button_up(id)
        super

        @repeatable_keys.detect do |key|
          if key[:key] == id
            key[:down] = false
            return true
          end
        end
      end

      def move(direction)
        pos = @text_input.caret_pos
        line = nil

        case direction
        when :up
          return if @active_line == 0
        when :down
          return if @active_line == @text_input.text.chomp.lines

          text = @text_input.text.chomp.lines[0..@active_line].join("\n")
          pos = text.length
        end

        set_position(pos)
      end

      def drag_update(_sender, x, y, _button)
        int = caret_position_under_mouse(x, y)
        int = 0 if int < 0
        @text_input.caret_pos = int

        :handled
      end
    end
  end
end
