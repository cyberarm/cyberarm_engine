module CyberarmEngine
  class Container
    include Common

    attr_accessor :stroke_color, :fill_color, :background_color, :x, :y, :z, :width, :height
    attr_reader :elements, :children, :options
    attr_reader :scroll_x, :scroll_y, :internal_width, :internal_height
    attr_reader :origin_x, :origin_y, :origin_width, :origin_height

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

      @x, @y, @z, @width, @height, @internal_width, @internal_height = x, y, z, width-x, height-y, width-x, height-y
      @origin_x, @origin_x = @x, @x
      @origin_width, @origin_height = @width, @height
      @scroll_x, @scroll_y = 0, 0
      @scroll_speed = 10

      @block = block
      @options = options

      @text_color = options[:text_color] || Element::THEME[:stroke]
      @background_color = Element::THEME[:background]

      @elements = []
      @children = []

      @theme = {}

      return self
    end

    def build
      @block.call(self) if @block

      recalculate
    end

    def add_child(container)
      @children << container
      @elements << container

      recalculate
    end

    def add(element)
      @elements << element

      recalculate
    end

    def draw
      Gosu.clip_to(@x, @y, @width, @height) do
        background

        Gosu.translate(@scroll_x, @scroll_y) do
          @elements.each(&:draw)
        end
      end
    end

    def update
      @elements.each(&:update)
    end

    def button_up(id)
      if $window.mouse_x.between?(@x, @x + @width)
        if $window.mouse_y.between?(@y, @y + @height)
          case id
          when Gosu::MsWheelUp
            @scroll_y += @scroll_speed
            @scroll_y  = 0 if @scroll_y > 0
          when Gosu::MsWheelDown
            @scroll_y -= @scroll_speed
            if $window.height - @internal_height - @y > 0
              @scroll_y = 0
            else
              @scroll_y = @height - @internal_height if @scroll_y <= @height - @internal_height
            end
          end
        end
      end

      @elements.each {|e| if defined?(e.button_up); e.button_up(id); end}
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

    def recalculate
      raise "mode was not defined!" unless @mode
      # puts "<#{self.class}:#{self.object_id}> X: #{@x}, Y: #{@y}, width: #{@width}, height: #{@height} (children: #{@children.count}, parents: #{@parent&.children&.count})"

      @packing_x = 0
      @packing_y = 0

      @width = @origin_width
      @height= @origin_height

      if @parent
        neighbors = @parent.children.size > 0 ? @parent.children.size : 1
        @width  = @parent.width  / neighbors
        @height = @parent.height / neighbors
      end

      widest_element  = nil
      last_element    = nil

      @elements.each do |element|
        flow(element)  if @mode == :flow
        stack(element) if @mode == :stack

        if element.is_a?(Element)
          widest_element  ||= element
          highest_element ||= element

          widest_element  = element if element.width > widest_element.width
          last_element    = element
        end

        margin = 0
        margin = element.margin if defined?(element.margin)
        case @mode
        when :flow
          @internal_width += element.width + margin unless @origin_width.nonzero?
          @internal_height = element.height + margin if element.height + margin > @internal_height + margin unless @origin_height.nonzero?
        when :stack
          @internal_width = element.width + margin if element.width + margin > @internal_width + margin unless @origin_width.nonzero?
          @internal_height += element.height + margin unless @origin_height.nonzero?
        end
      end

      @internal_width  += widest_element.margin if widest_element  && !@origin_width.nonzero?
      @internal_height += last_element.margin   if last_element && !@origin_height.nonzero?
    end

    def flow(element)
      element.x = @packing_x
      if element.is_a?(Container)
        element.y = @y
      else
        element.y = 0
      end
      element.recalculate

      @packing_x += element.margin if defined?(element.margin)
      @packing_x += element.width
    end

    def stack(element)
      if element.is_a?(Container)
        element.x = @x
      else
        element.x = 0
      end
      element.y = @packing_y
      element.recalculate

      @packing_y += element.margin if defined?(element.margin)
      @packing_y += element.height
    end
  end
end