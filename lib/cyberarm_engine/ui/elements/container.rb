module CyberarmEngine
  class Element
    class Container < Element
      include Common

      attr_accessor :stroke_color, :fill_color
      attr_reader :children, :gui_state, :scroll_position

      def self.current_container
        @@current_container
      end

      def self.current_container=(container)
        raise ArgumentError, "Expected container to an an instance of CyberarmEngine::Element::Container, got #{container.class}" unless container.is_a?(CyberarmEngine::Element::Container)

        @@current_container = container
      end

      def initialize(options = {}, block = nil)
        @gui_state = options.delete(:gui_state)
        super

        @last_scroll_position = Vector.new(0, 0)
        @scroll_position = Vector.new(0, 0)
        @scroll_target_position = Vector.new(0, 0)
        @scroll_speed = 80

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

      def remove(element)
        root.gui_state.request_recalculate if @children.delete(element)
      end

      def clear(&block)
        @children.clear

        old_container = CyberarmEngine::Element::Container.current_container

        CyberarmEngine::Element::Container.current_container = self
        block.call(self) if block

        CyberarmEngine::Element::Container.current_container = old_container

        root.gui_state.request_recalculate
      end

      def append(&block)
        old_container = CyberarmEngine::Element::Container.current_container

        CyberarmEngine::Element::Container.current_container = self
        block.call(self) if block

        CyberarmEngine::Element::Container.current_container = old_container

        root.gui_state.request_recalculate
      end

      def render
        Gosu.clip_to(
          @x + @style.border_thickness_left + @style.padding_left,
          @y + @style.border_thickness_top + @style.padding_top,
          content_width + 1,
          content_height + 1
        ) do
          Gosu.translate(@scroll_position.x, @scroll_position.y) do
            @children.each(&:draw)
          end
        end
      end

      def debug_draw
        super

        @children.each do |child|
          child.debug_draw
        end
      end

      def update
        update_scroll
        @children.each(&:update)
      end

      def hit_element?(x, y)
        return unless hit?(x, y)

        # Offset child hit point by scroll position/offset
        child_x = x - @scroll_position.x
        child_y = y - @scroll_position.y

        @children.reverse_each do |child|
          next unless child.visible?

          case child
          when Container
            if element = child.hit_element?(child_x, child_y)
              return element
            end
          else
            return child if child.hit?(child_x, child_y)
          end
        end

        self if hit?(x, y)
      end

      def update_child_element_visibity(child)
        child.element_visible = child.x >= (@x - @scroll_position.x) - child.width && child.x <= (@x - @scroll_position.x) + width &&
                                child.y >= (@y - @scroll_position.y) - child.height && child.y <= (@y - @scroll_position.y) + height
      end

      def update_scroll
        scroll_x_diff = (@scroll_target_position.x - @scroll_position.x)
        scroll_y_diff = (@scroll_target_position.y - @scroll_position.y)

        @scroll_position.x += (scroll_x_diff * 0.25).round
        @scroll_position.y += (scroll_y_diff * 0.25).round

        @scroll_position.x = @scroll_target_position.x if scroll_x_diff.abs < 1.0
        @scroll_position.y = @scroll_target_position.y if scroll_y_diff.abs < 1.0

        # Scrolled PAST top
        if @scroll_position.y > 0
          @scroll_target_position.y = 0

        # Scrolled PAST bottom
        elsif @scroll_position.y.abs > max_scroll_height
          @scroll_target_position.y = -max_scroll_height
        end

        if @last_scroll_position != @scroll_position
          @children.each { |child| update_child_element_visibity(child) }
          root.gui_state.request_repaint
        end

        @last_scroll_position.x = @scroll_position.x
        @last_scroll_position.y = @scroll_position.y
      end

      def recalculate
        @current_position = Vector.new(@style.margin_left + @style.padding_left, @style.margin_top + @style.padding_top)

        return unless visible?

        Stats.frame.increment(:gui_recalculations)

        stylize

        # s = Gosu.milliseconds

        layout

        old_width  = @width
        old_height = @height

        if is_root?
          @width  = @style.width  = window.width
          @height = @style.height = window.height
        else
          @width = 0
          @height = 0

          _width = dimensional_size(@style.width, :width)
          _height = dimensional_size(@style.height, :height)

          @width  = _width  || (@children.map { |c| c.x + c.outer_width }.max || 0).floor
          @height = _height || (@children.map { |c| c.y + c.outer_height }.max || 0).floor
        end

        # FIXME: Correctly handle alignment when element has siblings
        # FIXME: Enable alignment for any element, not just containers
        if @style.v_align
          space = space_available_height

          case @style.v_align
          when :center
            @y = parent.height / 2 - height / 2
          when :bottom
            @y = parent.height - height
          end
        end

        if @style.h_align
          space = space_available_width

          case @style.h_align
          when :center
            @x = parent.width / 2 - width / 2
          when :right
            @x = parent.width - width
          end
        end

        # Move children to parent after positioning
        @children.each do |child|
          child.x += (@x + @style.border_thickness_left) - style.margin_left
          child.y += (@y + @style.border_thickness_top) - style.margin_top

          child.stylize
          child.recalculate
          child.reposition # TODO: Implement top,bottom,left,center, and right positioning

          Stats.frame.increment(:gui_recalculations)

          update_child_element_visibity(child)
        end

        # puts "TOOK: #{Gosu.milliseconds - s}ms to recalculate #{self.class}:0x#{self.object_id.to_s(16)}"

        update_background

        # Fixes resized container scrolled past bottom
        self.scroll_top = -@scroll_position.y
        @scroll_target_position.y = @scroll_position.y

        root.gui_state.request_repaint if @width != old_width || @height != old_height
      end

      def layout
        raise "Not overridden"
      end

      def max_width
        # _width = dimensional_size(@style.width, :width)
        # if _width
        #   outer_width
        # else
        #   window.width - (@parent ? @parent.style.margin_right + @style.margin_right : @style.margin_right)
        # end

        outer_width
      end

      def fits_on_line?(element) # Flow
        @current_position.x + element.outer_width <= max_width &&
          @current_position.x + element.outer_width <= window.width
      end

      def position_on_current_line(element) # Flow
        element.x = element.style.margin_left + @current_position.x
        element.y = element.style.margin_top  + @current_position.y

        @current_position.x += element.outer_width
      end

      def tallest_neighbor(querier, _y_position) # Flow
        response = querier
        @children.each do |child|
          response = child if child.outer_height > response.outer_height
          break if child == querier
        end

        response
      end

      def position_on_next_line(element) # Flow
        @current_position.x = @style.margin_left + @style.padding_left
        @current_position.y += tallest_neighbor(element, @current_position.y).outer_height

        element.x = element.style.margin_left + @current_position.x
        element.y = element.style.margin_top  + @current_position.y

        @current_position.x += element.outer_width
      end

      def move_to_next_line(element) # Stack
        element.x = element.style.margin_left + @current_position.x
        element.y = element.style.margin_top  + @current_position.y

        @current_position.y += element.outer_height
      end

      def mouse_wheel_up(sender, x, y)
        return unless @style.scroll

        # Allow overscrolling UP, only if one can scroll DOWN
        if height < scroll_height
          if @scroll_target_position.y > 0
            @scroll_target_position.y = @scroll_speed
          else
            @scroll_target_position.y += @scroll_speed
          end

          return :handled
        end
      end

      def mouse_wheel_down(sender, x, y)
        return unless @style.scroll

        return unless height < scroll_height

        if @scroll_target_position.y > 0
          @scroll_target_position.y = -@scroll_speed
        else
          @scroll_target_position.y -= @scroll_speed
        end

        return :handled
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
        @children.map(&:class).join(", ")
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
