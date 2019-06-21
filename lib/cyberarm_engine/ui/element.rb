module CyberarmEngine
  class Element
    include Theme
    include Event
    include Common

    attr_accessor :x, :y, :z, :enabled
    attr_reader :width, :height, :parent, :options, :style, :event_handler, :background_canvas, :border_canvas

    def initialize(options = {}, block = nil)
      @parent = options[:parent] # parent Container (i.e. flow/stack)
      options = theme_defaults(options)
      @options = options
      @block = block

      @style             = Style.new(options)
      @focus             = false
      @style.background_canvas = Background.new
      @style.border_canvas     = BorderCanvas.new(element: self)

      @x = default(:x)
      @y = default(:y)
      @z = default(:z)

      @fixed_x = @x if @x != 0
      @fixed_y = @y if @y != 0

      @width  = default(:width)  || $window.width
      @height = default(:height) || $window.height

      set_border_thickness(default(:border_thickness))

      set_padding(default(:padding))

      set_margin(default(:margin))

      set_background(default(:background))
      set_border_color(default(:border_color))

      raise "#{self.class} 'x' must be a number" unless @x.is_a?(Numeric)
      raise "#{self.class} 'y' must be a number" unless @y.is_a?(Numeric)
      raise "#{self.class} 'z' must be a number" unless @z.is_a?(Numeric)
      raise "#{self.class} 'width' must be a number"  unless @width.is_a?(Numeric)  || @width.nil?
      raise "#{self.class} 'height' must be a number" unless @height.is_a?(Numeric) || @height.nil?
      raise "#{self.class} 'options' must be a Hash" unless @options.is_a?(Hash)

      # raise "#{self.class} 'padding' must be a number" unless @padding.is_a?(Numeric)

      @enabled = true
      @visible = true

      default_events
    end

    def set_background(background)
      @style.background = background
      @style.background_canvas.background = background
    end

    def set_border_thickness(border_thickness)
      @style.border_thickness = border_thickness

      @style.border_thickness_left   = default(:border_thickness_left)   || @style.border_thickness
      @style.border_thickness_right  = default(:border_thickness_right)  || @style.border_thickness
      @style.border_thickness_top    = default(:border_thickness_top)    || @style.border_thickness
      @style.border_thickness_bottom = default(:border_thickness_bottom) || @style.border_thickness
    end

    def set_border_color(color)
      @style.border_color = color

      @style.border_color_left   = default(:border_color_left)   || @style.border_color
      @style.border_color_right  = default(:border_color_right)  || @style.border_color
      @style.border_color_top    = default(:border_color_top)    || @style.border_color
      @style.border_color_bottom = default(:border_color_bottom) || @style.border_color

      @style.border_canvas.color = color
    end

    def set_padding(padding)
      @style.padding = padding

      @style.padding_left   = default(:padding_left)   || @style.padding
      @style.padding_right  = default(:padding_right)  || @style.padding
      @style.padding_top    = default(:padding_top)    || @style.padding
      @style.padding_bottom = default(:padding_bottom) || @style.padding
    end

    def set_margin(margin)
      @style.margin = margin

      @style.margin_left   = default(:margin_left)   || @style.margin
      @style.margin_right  = default(:margin_right)  || @style.margin
      @style.margin_top    = default(:margin_top)    || @style.margin
      @style.margin_bottom = default(:margin_bottom) || @style.margin
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

    def visible?
      @visible
    end

    def toggle
      @visible = !@visible
      root.recalculate
    end

    def show
      @visible = true
      root.recalculate
    end

    def hide
      @visible = false
      root.recalculate
    end

    def draw
      return unless @visible

      @style.background_canvas.draw
      @style.border_canvas.draw
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
      (@style.border_thickness_left + @style.padding_left) + @width + (@style.padding_right + @style.border_thickness_right)
    end

    def outer_width
      @style.margin_left + width + @style.margin_right
    end

    def height
      (@style.border_thickness_top + @style.padding_top) + @height + (@style.padding_bottom + @style.border_thickness_bottom)
    end

    def outer_height
      @style.margin_top + height + @style.margin_bottom
    end

    def background=(_background)
      @style.background_canvas.background=(_background)
      update_background
    end

    def update_background
      @style.background_canvas.x = @x
      @style.background_canvas.y = @y
      @style.background_canvas.z = @z
      @style.background_canvas.width  = width
      @style.background_canvas.height = height

      @style.background_canvas.update

      @style.border_canvas.update
    end

    def root
      unless @root && @root.parent.nil?
        @root = parent

        loop do
          if @root.parent.nil?
            break
          else
            @root = @root.parent
          end
        end
      end

      @root
    end

    def recalculate
      raise "#{self.class}#recalculate was not overridden!"
    end

    def reposition
      raise "#{self.class}#reposition was not overridden!"
    end

    def value
      raise "#{self.class}#value was not overridden!"
    end

    def value=(value)
      raise "#{self.class}#value= was not overridden!"
    end
  end
end