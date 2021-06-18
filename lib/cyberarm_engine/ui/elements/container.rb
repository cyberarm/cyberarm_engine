module CyberarmEngine
  class Element
    class Container < Element
      include Common

      attr_accessor :stroke_color, :fill_color
      attr_reader :children, :gui_state, :scroll_position

      def initialize(options = {}, block = nil)
        @gui_state = options.delete(:gui_state)
        super

        @scroll_position = Vector.new(0, 0)
        @scroll_speed = 40

        @text_color = options[:color]

        @children = []

        event(:window_size_changed)
      end

      def build
        @block.call(self) if @block

        root.gui_state.request_recalculate
      end

      def add(element)
        @children << element

        root.gui_state.request_recalculate
      end

      def clear(&block)
        @children.clear

        old_container = $__current_container__

        $__current_container__ = self
        block.call(self) if block

        $__current_container__ = old_container

        root.gui_state.request_recalculate
      end

      def apend(&block)
        old_container = $__current_container__

        $__current_container__ = self
        block.call(self) if block

        $__current_container__ = old_container

        root.gui_state.request_recalculate
      end

      def render
        Gosu.clip_to(@x, @y, width, height) do
          @children.each(&:draw)
        end
      end

      def debug_draw
        super

        @children.each do |child|
          child.debug_draw
        end
      end

      def update
        @children.each(&:update)
      end

      def hit_element?(x, y)
        return unless hit?(x, y)

        @children.reverse_each do |child|
          next unless child.visible?

          case child
          when Container
            if element = child.hit_element?(x, y)
              return element
            end
          else
            return child if child.hit?(x, y)
          end
        end

        self if hit?(x, y)
      end

      def recalculate
        @current_position = Vector.new(@style.margin_left + @style.padding_left, @style.margin_top + @style.padding_top)
        @current_position += @scroll_position

        return unless visible?

        Stats.increment(:gui_recalculations_last_frame, 1)

        stylize

        layout

        if is_root?
          @width  = @style.width  = window.width
          @height = @style.height = window.height
        else
          @width = 0
          @height = 0

          _width = dimensional_size(@style.width, :width)
          _height = dimensional_size(@style.height, :height)

          @width  = _width  || (@children.map { |c| c.x + c.outer_width }.max || 0).round
          @height = _height || (@children.map { |c| c.y + c.outer_height }.max || 0).round
        end

        # Move child to parent after positioning
        @children.each do |child|
          child.x += (@x + @style.border_thickness_left) - style.margin_left
          child.y += (@y + @style.border_thickness_top) - style.margin_top

          child.stylize
          child.recalculate
          child.reposition # TODO: Implement top,bottom,left,center, and right positioning

          Stats.increment(:gui_recalculations_last_frame, 1)
        end

        update_background
      end

      def layout
        raise "Not overridden"
      end

      def max_width
        _width = dimensional_size(@style.width, :width)
        if _width
          outer_width
        else
          window.width - (@parent ? @parent.style.margin_right + @style.margin_right : @style.margin_right)
        end
      end

      def fits_on_line?(element) # Flow
        p [@options[:id], @width] if @options[:id]
        @current_position.x + element.outer_width <= max_width &&
          @current_position.x + element.outer_width <= window.width
      end

      def position_on_current_line(element) # Flow
        element.x = element.style.margin_left + @current_position.x
        element.y = element.style.margin_top  + @current_position.y

        @current_position.x += element.outer_width
        @current_position.x = @style.margin_left if @current_position.x >= max_width
      end

      def tallest_neighbor(querier, _y_position) # Flow
        response = querier
        @children.each do |child|
          response = child if child.outer_height > response.outer_height
          break if child == querier
        end

        response
      end

      def position_on_next_line(child) # Flow
        @current_position.x = @style.margin_left
        @current_position.y += tallest_neighbor(child, @current_position.y).outer_height

        child.x = child.style.margin_left + @current_position.x
        child.y = child.style.margin_top  + @current_position.y

        @current_position.x += child.outer_width
      end

      def move_to_next_line(element) # Stack
        element.x = element.style.margin_left + @current_position.x
        element.y = element.style.margin_top  + @current_position.y

        @current_position.y += element.outer_height
      end

      def mouse_wheel_up(sender, x, y)
        return unless @style.scroll

        if @scroll_position.y < 0
          @scroll_position.y += @scroll_speed
          @scroll_position.y = 0 if @scroll_position.y > 0
          recalculate

          return :handled
        end
      end

      def mouse_wheel_down(sender, x, y)
        return unless @style.scroll

        return unless height < scroll_height

        if @scroll_position.y.abs < max_scroll_height
          @scroll_position.y -= @scroll_speed
          @scroll_position.y = -max_scroll_height if @scroll_position.y.abs > max_scroll_height
          recalculate

          return :handled
        end
      end

      def scroll_top
        @scroll_position.y
      end

      def scroll_top=(n)
        n = 0 if n <= 0
        @scroll_position.y = -n

        if max_scroll_height.positive?
          @scroll_position.y = -max_scroll_height if @scroll_position.y.abs > max_scroll_height
        else
          @scroll_position.y = 0
        end
      end

      def value
        @children.map { |c| c.class }.join(", ")
      end

      def to_s
        "#{self.class} x=#{x} y=#{y} width=#{width} height=#{height} children=#{@children.size}"
      end

      def write_tree(indent = "", _index = 0)
        puts self

        indent += "  "
        @children.each_with_index do |child, i|
          print "#{indent}#{i}: "

          if child.is_a?(Container)
            child.write_tree(indent)
          else
            puts child
          end
        end
      end
    end
  end
end
