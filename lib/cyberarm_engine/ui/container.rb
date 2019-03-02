module CyberarmEngine
  class Container < Element
    include Common

    attr_accessor :stroke_color, :fill_color, :background_color, :x, :y, :z, :width, :height
    attr_reader :children
    attr_reader :scroll_x, :scroll_y

    def initialize(options = {}, block = nil)
      super

      @origin_x, @origin_x = @x, @x
      @origin_width, @origin_height = @width, @height
      @scroll_x, @scroll_y = 0, 0
      @scroll_speed = 10

      @text_color = options[:text_color] || Element::THEME[:stroke]
      @background_color = Element::THEME[:background]

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

    def draw
      Gosu.clip_to(@x, @y, @width, @height) do
        background

        @children.each(&:draw)
      end
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

    def background
      Gosu.draw_rect(@x, @y, @width, @height, @background_color, @z)
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
      @current_position = Vector.new(@margin_left + @x, @margin_top + @y)

      layout

      @width  = @max_width  ? @max_width  : (@children.map {|c| c.x + c.width }.max + @margin_right  || 0)
      @height = @max_height ? @max_height : (@children.map {|c| c.y + c.height}.max + @margin_bottom || 0)
    end

    def layout
      raise "Not overridden"
    end

    def max_width
      @max_width ? @max_width : window.width
    end

    def fits_on_line?(element)
      @current_position.x + element.margin_left + element.width + element.margin_right <= max_width
    end

    def position_on_current_line(element)
      element.x = @current_position.x
      element.y = @current_position.y

      @current_position.x += element.width + element.margin_right
      @current_position.x = @margin_left + @x if @current_position.x >= max_width
    end

    def move_to_next_line(element)
      element.x = @current_position.x
      element.y = @current_position.y

      @current_position.y += element.height + element.margin_bottom
    end
  end
end