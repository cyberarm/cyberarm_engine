module CyberarmEngine
  class Element
    include Theme
    include Event

    attr_accessor :x, :y, :z, :width, :height, :padding, :margin, :enabled
    attr_reader :parent, :options, :event_handler

    def initialize(options = {}, block = nil)
      @parent = options[:parent] # parent Container (i.e. flow/stack)
      parent_theme = @parent ? @parent.theme : {}
      options = (THEME).merge(DEFAULTS).merge(parent_theme).merge(options)
      @options = options
      @block = block

      @x = options.dig(:x)
      @y = options.dig(:y)
      @z = options.dig(:z)

      @fixed_x = @x if @x != 0
      @fixed_y = @y if @y != 0

      @width  = options.dig(:width)
      @height = options.dig(:height)

      @padding = options.dig(:padding)
      @margin  = options.dig(:margin)

      raise "#{self.class} 'x' must be a number" unless @x.is_a?(Numeric)
      raise "#{self.class} 'y' must be a number" unless @y.is_a?(Numeric)
      raise "#{self.class} 'z' must be a number" unless @z.is_a?(Numeric)
      raise "#{self.class} 'width' must be a number" unless @width.is_a?(Numeric)
      raise "#{self.class} 'height' must be a number" unless @height.is_a?(Numeric)
      raise "#{self.class} 'options' must be a Hash" unless @options.is_a?(Hash)

      raise "#{self.class} 'padding' must be a number" unless @padding.is_a?(Numeric)
      raise "#{self.class} 'margin' must be a number" unless @margin.is_a?(Numeric)

      @max_width  = @width  if @width  != 0
      @max_height = @height if @height != 0

      @enabled = true

      default_events
    end

    def default_events
      [:left, :middle, :right].each do |button|
        event(:"#{button}_mouse_button")
        event(:"released_#{button}_mouse_button")
        event(:"holding_#{button}_mouse_button")
      end

      event(:mouse_wheel_up)
      event(:mouse_wheel_down)

      event(:enter)
      event(:hover)
      event(:leave)
    end

    def enabled?
      @enabled
    end

    def draw
    end

    def update
    end

    def button_down(id)
    end

    def button_up(id)
    end

    def hit?(x, y)
      x.between?(relative_x, relative_x + width) &&
      y.between?(relative_y, relative_y + height)
    end

    def width
      @width + (@padding * 2)
    end

    def height
      @height + (@padding * 2)
    end

    def outer_width
      width + (@margin * 2)
    end

    def outer_height
      height + (@margin * 2)
    end

    def relative_x
      @x# + @margin
    end

    def relative_y
      @y# + @margin
    end

    def recalculate
      raise "#{self.class}#recalculate was not overridden!"
    end

    def value
      raise "#{self.class}#value was not overridden!"
    end
  end
end