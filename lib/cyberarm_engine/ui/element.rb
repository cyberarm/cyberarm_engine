module CyberarmEngine
  class Element
    include Theme
    include Event
    include Common

    attr_accessor :x, :y, :z, :enabled, :tip
    attr_reader :parent, :options, :style, :event_handler, :background_canvas, :border_canvas

    def initialize(options = {}, block = nil)
      @parent = options.delete(:parent) # parent Container (i.e. flow/stack)
      options = theme_defaults(options)
      @options = options
      @block = block

      @focus   = false
      @enabled = true
      @visible = true
      @tip = @options[:tip] ? @options[:tip] : ""

      @style = Style.new(options)

      @x = @style.x
      @y = @style.y
      @z = @style.z

      @width  = 0
      @height = 0

      @fixed_x = @x if @x != 0
      @fixed_y = @y if @y != 0

      @style.width  = default(:width)  || nil
      @style.height = default(:height) || nil

      @style.background_canvas = Background.new
      @style.border_canvas     = BorderCanvas.new(element: self)

      stylize

      default_events
    end

    def stylize
      set_border_thickness(@style.border_thickness)

      set_padding(@style.padding)

      set_margin(@style.margin)

      set_background(@style.background)
      set_border_color(@style.border_color)
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
      root.gui_state.request_recalculate
    end

    def show
      @visible = true
      root.gui_state.request_recalculate
    end

    def hide
      @visible = false
      root.gui_state.request_recalculate
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

    def draggable?(button)
      false
    end

    def render
    end

    def hit?(x, y)
      x.between?(@x, @x + width) &&
      y.between?(@y, @y + height)
    end

    def width
      if visible?
        inner_width + @width
      else
        0
      end
    end

    def content_width
      @width
    end

    def noncontent_width
      (inner_width + outer_width) - width
    end

    def outer_width
      @style.margin_left + width + @style.margin_right
    end

    def inner_width
      (@style.border_thickness_left + @style.padding_left) + (@style.padding_right + @style.border_thickness_right)
    end

    def height
      if visible?
        inner_height + @height
      else
        0
      end
    end

    def content_height
      @height
    end

    def noncontent_height
      (inner_height + outer_height) - height
    end

    def outer_height
      @style.margin_top + height + @style.margin_bottom
    end

    def inner_height
      (@style.border_thickness_top + @style.padding_top) + (@style.padding_bottom + @style.border_thickness_bottom)
    end

    private def dimensional_size(size, dimension)
      raise "dimension must be either :width or :height" unless dimension == :width || dimension == :height
      if size && size.is_a?(Numeric)
        if size.between?(0.0, 1.0)
          ((@parent.send(:"content_#{dimension}") - self.send(:"noncontent_#{dimension}") - 1) * size).round
        else
          size
        end
      else
        nil
      end
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

    def is_root?
      @gui_state != nil
    end

    def recalculate
      raise "#{self.class}#recalculate was not overridden!"
    end

    def reposition
    end

    def value
      raise "#{self.class}#value was not overridden!"
    end

    def value=(value)
      raise "#{self.class}#value= was not overridden!"
    end
  end
end