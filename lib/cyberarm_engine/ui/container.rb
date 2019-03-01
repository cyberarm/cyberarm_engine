module CyberarmEngine
  class Container < Element
    include Common

    attr_accessor :stroke_color, :fill_color, :background_color, :x, :y, :z, :width, :height
    attr_reader :children, :options, :parent
    attr_reader :scroll_x, :scroll_y

    def initialize(options = {}, block = nil)
      @parent = options[:parent] || nil

      options = {
        x: 0, y: 0, z: 0,
        width: 0, height: 0
      }.merge(options)

      x = options.dig(:x)
      y = options.dig(:y)
      z = options.dig(:z)

      width  = options.dig(:width)
      height = options.dig(:height)

      raise "#{self.class} 'x' must be a number" unless x.is_a?(Numeric)
      raise "#{self.class} 'y' must be a number" unless y.is_a?(Numeric)
      raise "#{self.class} 'z' must be a number" unless z.is_a?(Numeric)
      raise "#{self.class} 'width' must be a number" unless width.is_a?(Numeric)
      raise "#{self.class} 'height' must be a number" unless height.is_a?(Numeric)
      raise "#{self.class} 'options' must be a Hash" unless options.is_a?(Hash)

      @x, @y, @z, @width, @height, = x, y, z, width, height
      @origin_x, @origin_x = @x, @x
      @origin_width, @origin_height = @width, @height
      @scroll_x, @scroll_y = 0, 0
      @scroll_speed = 10

      @block = block
      @options = options

      @text_color = options[:text_color] || Element::THEME[:stroke]
      @background_color = Element::THEME[:background]

      @children = []

      @theme = {}

      return self
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

    def mouse_over?
      $window.mouse_x.between?(@x, @x + @width) && $window.mouse_y.between?(@y, @y + @height)
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
      raise "mode was not defined!" unless @mode
      @current_position = Vector.new(@x, @y)

      layout
    end

    def layout
      raise "Not overridden"
    end

    def max_width
      @max_width ? @max_width : window.width
    end

    def fits_on_line?(element)
      @current_position.x + element.width <= max_width
    end

    def position_on_current_line(element)
      element.x = @current_position.x
      element.y = @current_position.y
      @current_position.x += element.width

      @current_position.x = @x if @current_position.x >= max_width
    end

    def move_to_next_line(element)
      element.x = @current_position.x
      element.y = @current_position.y
      @current_position.y += element.height
    end
  end
end