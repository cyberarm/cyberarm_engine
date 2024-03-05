module CyberarmEngine
  class Element
    class Slider < Container
      class Handle < Button
        def initialize(*args)
          super(*args)

          event(:begin_drag)
          event(:drag_update)
          event(:end_drag)

          subscribe :begin_drag do |_sender, x, y, _button|
            @drag_start_pos = Vector.new(x, y)

            :handled
          end

          subscribe :drag_update do |_sender, x, y, _button|
            @parent.handle_dragged_to(x, y)

            :handled
          end

          subscribe :end_drag do
            @drag_start_pos = nil

            :handled
          end
        end

        def draggable?(button)
          button == :left
        end
      end

      attr_reader :value
      attr_accessor :range, :step_size

      def initialize(options = {}, block = nil)
        super(options, block)

        @range     = @options[:range] || (0.0..1.0)
        @step_size = @options[:step] || 0.1
        @value     = @options[:value] || (@range.first + @range.last) / 2

        @handle = Handle.new("", parent: self, theme: options[:theme], width: 8, height: 1.0) { close }
        add(@handle)
      end

      def recalculate
        _width = dimensional_size(@style.width, :width)
        _height = dimensional_size(@style.height, :height)

        @width  = _width
        @height = _height

        position_handle
        @handle.recalculate
        @handle.update_background

        update_background
      end

      def position_handle
        @handle.x = @x + @handle.style.margin_left + @style.padding_left + @style.border_thickness_left +
                    ((content_width - @handle.outer_width) * (@value - @range.min) / (@range.max - @range.min).to_f)

        @handle.y = @y + @handle.style.margin_top + @style.border_thickness_top + @style.padding_top
      end

      def draw
        super

        @handle.draw
      end

      def update
        super

        @tip = format("%.2f", value.to_f)
        @handle.tip = @tip
      end

      def holding_left_mouse_button(_sender, x, y)
        handle_dragged_to(x, y)

        :handled
      end

      def handle_dragged_to(x, _y)
        @ratio = ((x - @handle.width / 2.0) - @x) / (content_width - @handle.outer_width.to_f)

        self.value = @ratio.clamp(0.0, 1.0) * (@range.max - @range.min) + @range.min
      end

      def value=(n)
        @value = n
        position_handle
        @handle.recalculate

        root.gui_state.request_repaint

        publish(:changed, @value)
      end
    end
  end
end
