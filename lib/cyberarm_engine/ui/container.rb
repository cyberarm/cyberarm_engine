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

    def stroke(color)
      @theme[:stroke] = color
    end

    def fill(color)
      @theme[:fill] = color
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

      layout

      @width  = @max_width  ? @max_width  : (@children.map {|c| c.x + c.width + c.margin_right}.max || 0).round
      @height = @max_height ? @max_height : (@children.map {|c| c.y + c.height+ c.margin_top  }.max || 0).round

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

    def fits_on_line?(element)
      @current_position.x + element.margin_left + element.width + element.margin_right <= max_width
    end

    def position_on_current_line(element)
      element.x = element.margin_left + @current_position.x
      element.y = element.margin_top  + @current_position.y

      element.recalculate

      @current_position.x += element.width + element.margin_right
      @current_position.x = @margin_left + @x if @current_position.x >= max_width
    end

    def move_to_next_line(element)
      element.x = element.margin_left + @current_position.x
      element.y = element.margin_top  + @current_position.y

      element.recalculate

      @current_position.y += element.height + element.margin_bottom
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