module CyberarmEngine
  class Container < Element
    include Common

    attr_accessor :stroke_color, :fill_color
    attr_reader :children
    attr_reader :scroll_x, :scroll_y

    def initialize(options = {}, block = nil)
      super

      @scroll_x, @scroll_y = 0, 0
      @scroll_speed = 10

      @text_color = options[:color]

      @children = []

      @theme = {}
    end

    def build
      @theme.merge(@parent.theme) if @parent
      @block.call(self) if @block

      recalculate
    end

    def add(element)
      @children << element

      recalculate
    end

    def render
        @children.each(&:draw)
    end

    def update
      @children.each(&:update)
    end

    def theme
      @theme
    end

    def color(color)
      @theme[:color] = color
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
      @current_position = Vector.new(@margin_left, @margin_top)
      unless @visible
        @width = 0
        @height= 0
        return
      end

      layout

      @width  = @max_width  ? @max_width  : (@children.map {|c| c.x + c.width  + c.margin_right }.max || 0).round
      @height = @max_height ? @max_height : (@children.map {|c| c.y + c.height + c.margin_bottom}.max || 0).round

      # Move child to parent after positioning
      @children.each do |child|
        child.x += @x
        child.y += @y

        # Fix child being displaced
        child.recalculate
      end

      update_background
    end

    def layout
      raise "Not overridden"
    end

    def max_width
      @max_width ? @max_width : window.width - (@parent ? @parent.margin_right + @margin_right : @margin_right)
    end

    def fits_on_line?(element) # Flow
      @current_position.x + element.outer_width <= max_width &&
      @current_position.x + element.outer_width <= window.width
    end

    def position_on_current_line(element) # Flow
      element.x = element.margin_left + @current_position.x
      element.y = element.margin_top  + @current_position.y

      element.recalculate

      @current_position.x += element.outer_width
      @current_position.x = @margin_left if @current_position.x >= max_width
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
      @current_position.x = @margin_left
      @current_position.y += tallest_neighbor(child, @current_position.y).outer_height

      child.x = child.margin_left + @current_position.x
      child.y = child.margin_top  + @current_position.y

      child.recalculate

      @current_position.x += child.outer_width
    end

    def move_to_next_line(element) # Stack
      element.x = element.margin_left + @current_position.x
      element.y = element.margin_top  + @current_position.y

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