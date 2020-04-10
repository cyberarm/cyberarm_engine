module CyberarmEngine
  class Element
    class Container < Element
      include Common

      attr_accessor :stroke_color, :fill_color
      attr_reader :children, :gui_state
      attr_reader :scroll_x, :scroll_y

      def initialize(options = {}, block = nil)
        @gui_state = options.delete(:gui_state)
        super

        @scroll_x, @scroll_y = 0, 0
        @scroll_speed = 10

        @text_color = options[:color]

        @children = []
      end

      def build
        @block.call(self) if @block

        recalculate
      end

      def add(element)
        @children << element

        recalculate
      end

      def clear(&block)
        @children.clear

        old_container = $__current_container__

        $__current_container__ = self
        block.call(self) if block

        $__current_container__ = old_container

        recalculate
        root.gui_state.request_recalculate
      end

      def render
        Gosu.clip_to(@x, @y, width, height) do
          @children.each(&:draw)
        end
      end

      def update
        @children.each(&:update)
      end

      def hit_element?(x, y)
        @children.reverse_each do |child|
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
        return unless visible?
        stylize

        layout

        if is_root?
          @width  = @style.width  = window.width
          @height = @style.height = window.height
        else
          @width, @height = 0, 0

          _width = dimensional_size(@style.width, :width)
          _height= dimensional_size(@style.height,:height)

          @width  = _width  ? _width  : (@children.map {|c| c.x + c.outer_width }.max || 0).round
          @height = _height ? _height : (@children.map {|c| c.y + c.outer_height}.max || 0).round
        end


        # Move child to parent after positioning
        @children.each do |child|
          child.x += (@x + @style.border_thickness_left) - style.margin_left
          child.y += (@y + @style.border_thickness_top) - style.margin_top

          child.stylize
          child.recalculate
          child.reposition # TODO: Implement top,bottom,left,center, and right positioning
        end

        update_background
      end

      def layout
        raise "Not overridden"
      end

      def max_width
        @max_width ? @max_width : window.width - (@parent ? @parent.style.margin_right + @style.margin_right : @style.margin_right)
      end

      def fits_on_line?(element) # Flow
        @current_position.x + element.outer_width <= max_width &&
        @current_position.x + element.outer_width <= window.width
      end

      def position_on_current_line(element) # Flow
        element.x = element.style.margin_left + @current_position.x
        element.y = element.style.margin_top  + @current_position.y

        element.recalculate

        @current_position.x += element.outer_width
        @current_position.x = @style.margin_left if @current_position.x >= max_width
      end

      def tallest_neighbor(querier, y_position) # Flow
        response = querier
        @children.each do |child|
          response = child if child.outer_height > response.outer_height
          break if child == querier
        end

        return response
      end

      def position_on_next_line(child) # Flow
        @current_position.x = @style.margin_left
        @current_position.y += tallest_neighbor(child, @current_position.y).outer_height

        child.x = child.style.margin_left + @current_position.x
        child.y = child.style.margin_top  + @current_position.y

        child.recalculate

        @current_position.x += child.outer_width
      end

      def move_to_next_line(element) # Stack
        element.x = element.style.margin_left + @current_position.x
        element.y = element.style.margin_top  + @current_position.y

        element.recalculate

        @current_position.y += element.outer_height
      end

      # def mouse_wheel_up(sender, x, y)
      #   @children.each {|c| c.y -= @scroll_speed}
      #   @children.each {|c| c.recalculate}
      # end

      # def mouse_wheel_down(sender, x, y)
      #   @children.each {|c| c.y += @scroll_speed}
      #   @children.each {|c| c.recalculate}
      # end

      def value
        @children.map {|c| c.class}.join(", ")
      end
    end
  end
end
