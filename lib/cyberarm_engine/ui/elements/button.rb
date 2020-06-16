module CyberarmEngine
  class Element
    class Button < Label
      def initialize(text_or_image, options = {}, block = nil)
        @image, @scale_x, @scale_y = nil, 1, 1

        if text_or_image.is_a?(Gosu::Image)
          @image = text_or_image
        end

        super(text_or_image, options, block)

        @style.background_canvas.background = default(:background)
      end

      def render
        if @image
          draw_image
        else
          draw_text
        end
      end

      def draw_image
        @image.draw(
          @style.border_thickness_left + @style.padding_left + @x,
          @style.border_thickness_top + @style.padding_top + @y,
          @z + 2,
          @scale_x, @scale_y, @text.color)
      end

      def draw_text
        @text.draw
      end

      def enter(sender)
        @focus = false unless window.button_down?(Gosu::MsLeft)

        if @focus
          @style.background_canvas.background = default(:active, :background)
          @text.color = default(:active, :color)
        else
          @style.background_canvas.background = default(:hover, :background)
          @text.color = default(:hover, :color)
        end

        return :handled
      end

      def left_mouse_button(sender, x, y)
        @focus = true
        @style.background_canvas.background = default(:active, :background)
        window.current_state.focus = self
        @text.color = default(:active, :color)

        return :handled
      end

      def released_left_mouse_button(sender,x, y)
        enter(sender)

        return :handled
      end

      def clicked_left_mouse_button(sender, x, y)
        @block.call(self) if @block

        return :handled
      end

      def leave(sender)
        @style.background_canvas.background = default(:background)
        @text.color = default(:color)

        return :handled
      end

      def blur(sender)
        @focus = false

        return :handled
      end

      def recalculate
        if @image
          @width, @height = 0, 0

          _width = dimensional_size(@style.image_width, :width)
          _height= dimensional_size(@style.image_height,:height)

          if _width && _height
            @scale_x = _width.to_f / @image.width
            @scale_y = _height.to_f / @image.height
          elsif _width
            @scale_x = _width.to_f / @image.width
            @scale_y = @scale_x
          elsif _height
            @scale_y = _height.to_f / @image.height
            @scale_x = @scale_y
          else
            @scale_x, @scale_y = 1, 1
          end

          @width = _width  ? _width  : @image.width.round * @scale_x
          @height= _height ? _height : @image.height.round * @scale_y

          update_background
        else
          super
        end
      end

      def value
        @image ? @image : super
      end

      def value=(value)
        if value.is_a?(Gosu::Image)
          @image = value
        else
          super
        end

        old_width, old_height = width, height
        recalculate

        root.gui_state.request_recalculate if old_width != width || old_height != height

        publish(:changed, self.value)
      end
    end
  end
end