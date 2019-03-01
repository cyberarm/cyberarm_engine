module CyberarmEngine
  class Element
    include Theme
    include Event
    include Common

    attr_accessor :x, :y, :z, :width, :height, :enabled
    attr_reader :parent, :options, :event_handler
    attr_reader :padding, :padding_left, :padding_right, :padding_top, :padding_bottom
    attr_reader :margin, :margin_left, :margin_right, :margin_top, :margin_bottom

    def initialize(options = {}, block = nil)
      @parent = options[:parent] # parent Container (i.e. flow/stack)
      options = (THEME).merge(DEFAULTS).merge(options)
      @options = options
      @block = block

      @x = options.dig(:x)
      @y = options.dig(:y)
      @z = options.dig(:z)

      @fixed_x = @x if @x != 0
      @fixed_y = @y if @y != 0

      @width  = options.dig(:width)
      @height = options.dig(:height)

      set_padding(options.dig(:padding))
      @padding_left   = options.dig(:padding_left)   || @padding
      @padding_right  = options.dig(:padding_right)  || @padding
      @padding_top    = options.dig(:padding_top)    || @padding
      @padding_bottom = options.dig(:padding_bottom) || @padding

      set_margin(options.dig(:margin))
      @margin_left   = options.dig(:margin_left)   || @margin
      @margin_right  = options.dig(:margin_right)  || @margin
      @margin_top    = options.dig(:margin_top)    || @margin
      @margin_bottom = options.dig(:margin_bottom) || @margin

      raise "#{self.class} 'x' must be a number" unless @x.is_a?(Numeric)
      raise "#{self.class} 'y' must be a number" unless @y.is_a?(Numeric)
      raise "#{self.class} 'z' must be a number" unless @z.is_a?(Numeric)
      raise "#{self.class} 'width' must be a number" unless @width.is_a?(Numeric)
      raise "#{self.class} 'height' must be a number" unless @height.is_a?(Numeric)
      raise "#{self.class} 'options' must be a Hash" unless @options.is_a?(Hash)

      # raise "#{self.class} 'padding' must be a number" unless @padding.is_a?(Numeric)

      @max_width  = @width  if @width  != 0
      @max_height = @height if @height != 0

      @enabled = true

      default_events
    end

    def set_padding(padding)
      @padding = padding

      @padding_left   = padding
      @padding_right  = padding
      @padding_top    = padding
      @padding_bottom = padding
    end

    def set_margin(margin)
      @margin = margin

      @margin_left   = margin
      @margin_right  = margin
      @margin_top    = margin
      @margin_bottom = margin
    end

    def default_events
      [:left, :middle, :right].each do |button|
        event(:"#{button}_mouse_button")
        event(:"released_#{button}_mouse_button")
        event(:"clicked_#{button}_mouse_button")
        event(:"holding_#{button}_mouse_button")
      end

      event(:mouse_wheel_up)
      event(:mouse_wheel_down)

      event(:enter)
      event(:hover)
      event(:leave)

      event(:blur)
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
      x.between?(@x, @x + width) &&
      y.between?(@y, @y + height)
    end

    def width
      @padding_left + @width + @padding_right
    end

    def height
      @padding_top + @height + @padding_bottom
    end

    def recalculate
      raise "#{self.class}#recalculate was not overridden!"
    end

    def value
      raise "#{self.class}#value was not overridden!"
    end
  end
end