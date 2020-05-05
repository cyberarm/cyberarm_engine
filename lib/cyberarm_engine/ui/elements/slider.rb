module CyberarmEngine
  class Element
    class Slider < Container
      class Handle < Button
        def initialize(*args)
          super(*args)

          event(:begin_drag)
          event(:drag_update)
          event(:end_drag)

          subscribe :begin_drag do |sender, x, y, button|
            @drag_start_pos = Vector.new(x, y)

            :handled
          end

          subscribe :drag_update do |sender, x, y, button|
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

      attr_reader :range, :step_size
      def initialize(options = {}, block = nil)
        super(options, block)

        @range     = @options[:range] ? @options[:range] : 0.0..1.0
        @step_size = @options[:step] ? @options[:step] : 0.1
        @value     = @options[:value] ? @options[:value] : 0.5

        @handle = Handle.new("", parent: self, width: 8, height: 1.0) { close }
        self.add(@handle)
      end

      def recalculate
        _width = dimensional_size(@style.width, :width)
        _height= dimensional_size(@style.height,:height)

        @width  = _width
        @height = _height

        @handle.x = @x + @style.border_thickness_left + @style.padding_left
        @handle.y = @y + @style.border_thickness_top + @style.padding_top
        @handle.recalculate
        @handle.update_background

        # pp @handle.height

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

        :handled
      end

      def handle_dragged_to(x, y)
        puts
        pp x, y, @handle.width, content_width
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

        publish(:changed, @value)
      end
    end
  end
end