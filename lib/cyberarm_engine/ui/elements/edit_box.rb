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
            action: proc {move(:up)}
          },
          {
            key: Gosu::KB_DOWN,
            down: false,
            repeat_delay: 50,
            last_repeat: 0,
            action: proc {move(:down)}
          }
        ]
      end

      def update
        super

        caret_stay_left_of_last_newline
        calculate_active_line

        @repeatable_keys.each do |key|
          if key[:down]
            if Gosu.milliseconds > key[:last_repeat] + key[:repeat_delay]
              key[:action].call
              key[:last_repeat] = Gosu.milliseconds
            end
          end
        end
      end

      def draw_caret
        Gosu.draw_rect(caret_position, @text.y + @active_line * @text.textobject.height, @caret_width, @caret_height, @caret_color, @z)
      end

      def draw_selection
        selection_width = caret_position - selection_start_position

        Gosu.draw_rect(selection_start_position, @text.y, selection_width, @text.textobject.height, default(:selection_color), @z)
      end

      def text_input_position_for(method)
        if @type == :password
          @text.x + @text.width(default(:password_character) * @text_input.text[0...@text_input.send(method)].length)
        else
          @text.x + @text.width(@text_input.text[0...@text_input.send(method)])
        end
      end

      def set_position(int)
        @text_input.selection_start = @text_input.caret_pos = int
      end

      def calculate_active_line
        sub_text = @text_input.text[0...@text_input.caret_pos]
        @active_line = sub_text.lines.size-1
      end

      def caret_stay_left_of_last_newline
        @text_input.text+="\n" unless @text_input.text.end_with?("\n")

        eof = @text_input.text.chomp.length
        set_position(eof) if @text_input.caret_pos > eof
      end

      def caret_position_under_mouse(mouse_x, mouse_y)
        active_line = ((mouse_y - @text.y) / @text.textobject.height).round
        active_line = 0 if @active_line < 0
        active_line = @text.text.strip.lines.size if @active_line > @text.text.strip.lines.size

        # 1.upto(@text.text.length) do |i|
        #   if mouse_x < @text.x - @offset_x + @text.width(@text.text[0...i])
        #     return i - 1
        #   end
        # end
        buffer = ""
        @text.text.strip.lines.each do |line|
          buffer.length.upto(line.length) do |i|
            if mouse_x < @text.x - @offset_x + @text.width(@text.text[buffer.length...i])
              puts "#{i}"
              return i - 1
            end
          end

          buffer += line
        end

        @text_input.text.length
      end

      def move_caret_to_mouse(mouse_x, mouse_y)
        @text_input.caret_pos = @text_input.selection_start = caret_position_under_mouse(mouse_x, mouse_y)
      end

      def button_down(id)
        super

        @repeatable_keys.detect do |key|
          if key[:key] == id
            key[:down] = true
            key[:last_repeat] = Gosu.milliseconds + key[:repeat_delay]
            return true
          end
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

      def drag_update(sender, x, y, button)
        @text_input.caret_pos = caret_position_under_mouse(x, y)

        :handled
      end
    end
  end
end