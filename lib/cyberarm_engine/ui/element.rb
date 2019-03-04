module CyberarmEngine
  class Element
    include Theme
    include Event
    include Common

    attr_accessor :x, :y, :z, :width, :height, :enabled
    attr_reader :parent, :options, :event_handler, :background_canvas, :border_canvas

    attr_reader :border_thickness, :border_thickness_left, :border_thickness_right, :border_thickness_top, :border_thickness_bottom
    attr_reader :border_color, :border_color_left, :border_color_right, :border_color_top, :border_color_bottom

    attr_reader :padding, :padding_left, :padding_right, :padding_top, :padding_bottom
    attr_reader :margin, :margin_left, :margin_right, :margin_top, :margin_bottom

    def initialize(options = {}, block = nil)
      @parent = options[:parent] # parent Container (i.e. flow/stack)
      options = (THEME).merge(DEFAULTS).merge(options)
      @options = options
      @block = block

      @background_canvas = Background.new
      @border_canvas     = BorderCanvas.new(element: self)

      @x = options.dig(:x)
      @y = options.dig(:y)
      @z = options.dig(:z)

      @fixed_x = @x if @x != 0
      @fixed_y = @y if @y != 0

      @width  = options.dig(:width)
      @height = options.dig(:height)

      set_border_thickness(options.dig(:border_thickness))

      set_padding(options.dig(:padding))

      set_margin(options.dig(:margin))

      set_background(options.dig(:background))
      set_border_color(options.dig(:border_color))

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

    def set_background(background)
      @background = background
      @background_canvas.background = background
    end

    def set_border_thickness(border_thickness)
      @border_thickness = border_thickness

      @border_thickness_left   = options.dig(:border_thickness_left)   || @border_thickness
      @border_thickness_right  = options.dig(:border_thickness_right)  || @border_thickness
      @border_thickness_top    = options.dig(:border_thickness_top)    || @border_thickness
      @border_thickness_bottom = options.dig(:border_thickness_bottom) || @border_thickness
    end

    def set_border_color(color)
      @border_color = color

      @border_color_left   = options.dig(:border_color_left)   || @border_color
      @border_color_right  = options.dig(:border_color_right)  || @border_color
      @border_color_top    = options.dig(:border_color_top)    || @border_color
      @border_color_bottom = options.dig(:border_color_bottom) || @border_color

      @border_canvas.color = color
    end

    def set_padding(padding)
      @padding = padding

      @padding_left   = options.dig(:padding_left)   || @padding
      @padding_right  = options.dig(:padding_right)  || @padding
      @padding_top    = options.dig(:padding_top)    || @padding
      @padding_bottom = options.dig(:padding_bottom) || @padding
    end

    def set_margin(margin)
      @margin = margin

      @margin_left   = options.dig(:margin_left)   || @margin
      @margin_right  = options.dig(:margin_right)  || @margin
      @margin_top    = options.dig(:margin_top)    || @margin
      @margin_bottom = options.dig(:margin_bottom) || @margin
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
      @background_canvas.draw
      @border_canvas.draw
      render
    end

    def update
    end

    def button_down(id)
    end

    def button_up(id)
    end

    def render
    end

    def hit?(x, y)
      x.between?(@x, @x + width) &&
      y.between?(@y, @y + height)
    end

    def width
      @border_thickness_left + @padding_left + @width + @padding_right + @border_thickness_right
    end

    def height
      @border_thickness_top + @padding_top + @height + @padding_bottom + @border_thickness_bottom
    end

    def background=(_background)
      @background_canvas.background=(_background)
      update_background
    end

    def update_background
      @background_canvas.x = @x
      @background_canvas.y = @y
      @background_canvas.z = @z
      @background_canvas.width  = width
      @background_canvas.height = height

      @background_canvas.update

      @border_canvas.update
    end

    def recalculate
      raise "#{self.class}#recalculate was not overridden!"
    end

    def value
      raise "#{self.class}#value was not overridden!"
    end
  end
end