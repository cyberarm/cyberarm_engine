module CyberarmEngine
  class Element
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

        @offset_x = 0

        return self
      end

      def render
        Gosu.clip_to(@text.x, @text.y, @style.width, @text.height) do
          Gosu.translate(-@offset_x, 0) do
            draw_selection
            draw_caret if @focus && @show_caret
            draw_text
          end
        end
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

        if Gosu.milliseconds >= @caret_last_interval + @caret_interval
          @caret_last_interval = Gosu.milliseconds

          @show_caret = !@show_caret
        end

        keep_caret_visible
      end

      def move_caret_to_mouse(mouse_x)
        1.upto(@text.text.length) do |i|
          if mouse_x < @text.x + @text.textobject.text_width(@text.text[0...i])
            @text_input.caret_pos = @text_input.selection_start = i - 1;
            return
          end
        end

        @text_input.caret_pos = @text_input.selection_start = @text_input.text.length
      end

      def keep_caret_visible
        caret_pos = (caret_position - @text.x) + @caret_width

        @last_text ||= "/\\"
        @last_pos ||= -1

        puts "caret pos: #{caret_pos}, width: #{@width}, offset: #{@offset_x}" if (@last_text != @text.text) || (@last_pos != caret_pos)

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
          puts "triggered"

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
          @text.x + @text.width(default(:password_character) * @text_input.text[0..@text_input.send(method)].length)
        else
          @text.x + @text.width(@text_input.text[0..@text_input.send(method)])
        end
      end

      def left_mouse_button(sender, x, y)
        super
        window.text_input = @text_input

        @caret_last_interval = Gosu.milliseconds
        @show_caret = true

        move_caret_to_mouse(x)

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