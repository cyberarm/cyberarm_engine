module CyberarmEngine
  class Element
    class Slider < Container
      class Handle < Button
        def initialize(*args)
          super(*args)

          event(:begin_drag)
          event(:drag_update)
          event(:end_drag)
        end

        def draggable?(button)
          button == :left
        end

        def begin_drag(sender, x, y, button)
          @drag_start_pos = Vector.new(x, y)

          :handled
        end

        def drag_update(sender, x, y, button)
          # ratio = (@parent.x - (x - @drag_start_pos.x) / (@parent.width - width) * -1).clamp(0.0, 1.0)
          # @x = @parent.x + width + ((@parent.width * ratio) - width * 2)
          @parent.handle_dragged_to(x, y)

          :handled
        end

        def end_drag(sender, x, y, button)
          @drag_start_pos = nil

          :handled
        end
      end

      attr_reader :range, :step_size
      def initialize(options = {}, block = nil)
        super(options, block)

        @range     = @options[:range] ? @options[:range] : 0.0..1.0
        @step_size = @options[:step] ? @options[:step] : 0.1
        @value     = @options[:value] ? @options[:value] : 0.5

        @handle = Handle.new("", parent: self, width: 8) { close }
        self.add(@handle)
      end

      def recalculate
        _width = dimensional_size(@style.width, :width)
        _height= dimensional_size(@style.height,:height)

        @width  = _width
        @height = _height

        @handle.x = @x + @style.border_thickness_left + @style.padding_left
        @handle.y = @y + @style.border_thickness_top + @style.padding_left
        @handle.recalculate

        update_background
      end

      def draw
        super

        @handle.draw
      end

      def update
        super

        @tip = value.to_s
        @handle.tip = @tip
      end

      def holding_left_mouse_button(sender, x, y)
        handle_dragged_to(x, y)
      end

      def handle_dragged_to(x, y)
        @ratio = ((x - @handle.width) - @x) / content_width

        # p [@ratio, @value]
        self.value = @ratio.clamp(0.0, 1.0) * (@range.max - @range.min) + @range.min

      end

      def value
        @value
      end

      def value=(n)
        @value = n
        @handle.x = @x + @style.padding_left + @style.border_thickness_left +
                    (content_width * (@value - @range.min) / (@range.max - @range.min).to_f)
        @handle.recalculate
      end
    end
  end
end