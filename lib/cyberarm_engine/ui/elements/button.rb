module CyberarmEngine
  class Element
    class Button < Label
      def initialize(text_or_image, options = {}, block = nil)
        @image = nil
        @scale_x = 1
        @scale_y = 1

        @image = text_or_image if text_or_image.is_a?(Gosu::Image)

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
          @scale_x, @scale_y, @text.color
        )
      end

      def draw_text
        @text.draw
      end

      def enter(_sender)
        @focus = false unless window.button_down?(Gosu::MsLeft)

        if @focus
          @style.background_canvas.background = default(:active, :background)
          @text.color = default(:active, :color)
        else
          @style.background_canvas.background = default(:hover, :background)
          @text.color = default(:hover, :color)
        end

        :handled
      end

      def left_mouse_button(_sender, _x, _y)
        @focus = true
        @style.background_canvas.background = default(:active, :background)
        window.current_state.focus = self
        @text.color = default(:active, :color)

        :handled
      end

      def released_left_mouse_button(sender, _x, _y)
        enter(sender)

        :handled
      end

      def clicked_left_mouse_button(_sender, _x, _y)
        @block.call(self) if @block

        :handled
      end

      def leave(_sender)
        @style.background_canvas.background = default(:background)
        @text.color = default(:color)

        :handled
      end

      def blur(_sender)
        @focus = false

        :handled
      end

      def recalculate
        if @image
          @width = 0
          @height = 0

          _width = dimensional_size(@style.image_width, :width)
          _height = dimensional_size(@style.image_height, :height)

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
            @scale_x = 1
            @scale_y = 1
          end

          @width = _width || @image.width.round * @scale_x
          @height = _height || @image.height.round * @scale_y

          update_background
        else
          super
        end
      end

      def value
        @image || super
      end

      def value=(value)
        if value.is_a?(Gosu::Image)
          @image = value
        else
          super
        end

        old_width = width
        old_height = height
        recalculate

        root.gui_state.request_recalculate if old_width != width || old_height != height

        publish(:changed, self.value)
      end
    end
  end
end
