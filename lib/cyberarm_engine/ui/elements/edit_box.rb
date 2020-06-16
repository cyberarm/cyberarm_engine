module CyberarmEngine
  class Element
    class EditBox < EditLine
      def initialize(*args)
        super(*args)

        @active_line = 0
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

      def caret_position_under_mouse(mouse_x, mouse_y)
        1.upto(@text.text.length) do |i|
          if mouse_x < @text.x - @offset_x + @text.textobject.text_width(@text.text[0...i])
            return i - 1;
          end
        end

        @text_input.text.length
      end

      def move_caret_to_mouse(mouse_x, mouse_y)
        @text_input.caret_pos = @text_input.selection_start = caret_position_under_mouse(mouse_x, mouse_y)
      end

      def button_down(id)
        super

        case id
        when Gosu::KB_ENTER, Gosu::KB_RETURN
          caret_pos = @text_input.caret_pos
          @text_input.text = @text_input.text.insert(@text_input.caret_pos, "\n")
          @text_input.caret_pos = @text_input.selection_start = caret_pos + 1
        end
      end

      def drag_update(sender, x, y, button)
        @text_input.caret_pos = caret_position_under_mouse(x, y)

        :handled
      end
    end
  end
end