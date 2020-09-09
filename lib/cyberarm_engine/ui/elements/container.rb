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

      def render
        Gosu.clip_to(@x, @y, width, height) do
          @children.each(&:draw)
        end

        if false#DEBUG
          Gosu.flush

          Gosu.draw_line(
            self.x, self.y, Gosu::Color::RED,
            self.x + outer_width, self.y, Gosu::Color::RED,
            Float::INFINITY
          )
          Gosu.draw_line(
            self.x + outer_width, self.y, Gosu::Color::RED,
            self.x + outer_width, self.y + outer_height, Gosu::Color::RED,
            Float::INFINITY
          )
          Gosu.draw_line(
            self.x + outer_width, self.y + outer_height, Gosu::Color::RED,
            self.x, self.y + outer_height, Gosu::Color::RED,
            Float::INFINITY
          )
          Gosu.draw_line(
            self.x, outer_height, Gosu::Color::RED,
            self.x, self.y, Gosu::Color::RED,
            Float::INFINITY
          )
        end
      end

      def update
        @children.each(&:update)
      end

      def hit_element?(x, y)
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
        return unless visible?

        Stats.increment(:gui_recalculations_last_frame, 1)

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

          Stats.increment(:gui_recalculations_last_frame, 1)
        end

        update_background
      end

      def layout
        raise "Not overridden"
      end

      def max_width
        _width = dimensional_size(@style.width, :width)
        _width ? outer_width : window.width - (@parent ? @parent.style.margin_right + @style.margin_right : @style.margin_right)
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

        @current_position.x += child.outer_width
      end

      def move_to_next_line(element) # Stack
        element.x = element.style.margin_left + @current_position.x
        element.y = element.style.margin_top  + @current_position.y

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

      def to_s
        "#{self.class} x=#{x} y=#{y} width=#{width} height=#{height} children=#{@children.size}"
      end

      def write_tree(indent = "", index = 0)
        puts self

        indent = indent + "  "
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
