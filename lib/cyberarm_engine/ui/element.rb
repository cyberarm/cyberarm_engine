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

      @focus   = @options[:focus].nil?   ? false : @options[:focus]
      @enabled = @options[:enabled].nil? ? true  : @options[:enabled]
      @visible = @options[:visible].nil? ? true  : @options[:visible]
      @tip     = @options[:tip] || ""

      @debug_color = @options[:debug_color].nil? ? Gosu::Color::RED : @options[:debug_color]

      @style = Style.new(options)

      @root ||= nil
      @gui_state ||= nil

      @x = @style.x
      @y = @style.y
      @z = @style.z

      @width  = 0
      @height = 0

      @style.width  = default(:width)  || nil
      @style.height = default(:height) || nil

      @style.background_canvas = Background.new
      @style.background_nine_slice_canvas = BackgroundNineSlice.new
      @style.border_canvas = BorderCanvas.new(element: self)

      @style_event = :default

      stylize

      default_events

      root.gui_state.request_focus(self) if @options[:autofocus]
    end

    def stylize
      set_static_position

      set_padding
      set_margin

      set_background
      set_background_nine_slice

      set_border_thickness
      set_border_color
    end

    def safe_style_fetch(*args)
      @style.hash.dig(@style_event, *args) || @style.hash.dig(:default, *args) || default(*args)
    end

    def set_static_position
      @x = @style.x if @style.x != 0
      @y = @style.y if @style.y != 0
    end

    def set_background
      @style.background = safe_style_fetch(:background)

      @style.background_canvas.background = @style.background
    end

    def set_background_nine_slice
      @style.background_nine_slice = safe_style_fetch(:background_nine_slice)

      @style.background_nine_slice_mode = safe_style_fetch(:background_nine_slice_mode) || :stretch
      @style.background_nine_slice_color = safe_style_fetch(:background_nine_slice_color) || Gosu::Color::WHITE
      @style.background_nine_slice_canvas.color = @style.background_nine_slice_color

      @style.background_nine_slice_from_edge = safe_style_fetch(:background_nine_slice_from_edge)

      @style.background_nine_slice_left      = safe_style_fetch(:background_nine_slice_left)   || @style.background_nine_slice_from_edge
      @style.background_nine_slice_top       = safe_style_fetch(:background_nine_slice_top)    || @style.background_nine_slice_from_edge
      @style.background_nine_slice_right     = safe_style_fetch(:background_nine_slice_right)  || @style.background_nine_slice_from_edge
      @style.background_nine_slice_bottom    = safe_style_fetch(:background_nine_slice_bottom) || @style.background_nine_slice_from_edge
    end

    def set_border_thickness
      @style.border_thickness = safe_style_fetch(:border_thickness)

      @style.border_thickness_left   = safe_style_fetch(:border_thickness_left)   || @style.border_thickness
      @style.border_thickness_right  = safe_style_fetch(:border_thickness_right)  || @style.border_thickness
      @style.border_thickness_top    = safe_style_fetch(:border_thickness_top)    || @style.border_thickness
      @style.border_thickness_bottom = safe_style_fetch(:border_thickness_bottom) || @style.border_thickness
    end

    def set_border_color
      @style.border_color = safe_style_fetch(:border_color)

      @style.border_color_left   = safe_style_fetch(:border_color_left)   || @style.border_color
      @style.border_color_right  = safe_style_fetch(:border_color_right)  || @style.border_color
      @style.border_color_top    = safe_style_fetch(:border_color_top)    || @style.border_color
      @style.border_color_bottom = safe_style_fetch(:border_color_bottom) || @style.border_color

      @style.border_canvas.color = [
        @style.border_color_top,
        @style.border_color_right,
        @style.border_color_bottom,
        @style.border_color_left
      ]
    end

    def set_padding
      @style.padding = safe_style_fetch(:padding)

      @style.padding_left   = safe_style_fetch(:padding_left)   || @style.padding
      @style.padding_right  = safe_style_fetch(:padding_right)  || @style.padding
      @style.padding_top    = safe_style_fetch(:padding_top)    || @style.padding
      @style.padding_bottom = safe_style_fetch(:padding_bottom) || @style.padding
    end

    def set_margin
      @style.margin = safe_style_fetch(:margin)

      @style.margin_left   = safe_style_fetch(:margin_left)   || @style.margin
      @style.margin_right  = safe_style_fetch(:margin_right)  || @style.margin
      @style.margin_top    = safe_style_fetch(:margin_top)    || @style.margin
      @style.margin_bottom = safe_style_fetch(:margin_bottom) || @style.margin
    end

    def update_styles(event = :default)
      old_width = width
      old_height = height

      _style = @style.send(event)
      @style_event = event

      if @text.is_a?(CyberarmEngine::Text)
        @text.color = _style&.dig(:color) || @style.default[:color]
        @text.swap_font(_style&.dig(:text_size) || @style.default[:text_size], _style&.dig(:font) || @style.default[:font])
      end

      return if self.is_a?(ToolTip)

      if old_width != width || old_height != height
        (root&.gui_state || @gui_state).request_recalculate
      else
        stylize
      end
    end

    def default_events
      %i[left middle right].each do |button|
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

      event(:focus)
      event(:blur)

      event(:changed)
    end

    def enter(_sender)
      @focus = false unless window.button_down?(Gosu::MsLeft)

      if !@enabled
        update_styles(:disabled)
      elsif @focus
        update_styles(:active)
      else
        update_styles(:hover)
      end

      :handled
    end

    def left_mouse_button(_sender, _x, _y)
      @focus = true

      unless @enabled
        update_styles(:disabled)
      else
        update_styles(:active)
      end

      window.current_state.focus = self

      :handled
    end

    def released_left_mouse_button(sender, _x, _y)
      enter(sender)

      :handled
    end

    def clicked_left_mouse_button(_sender, _x, _y)
      @block&.call(self) if @enabled && !self.is_a?(Container)

      :handled
    end

    def leave(_sender)
      if @enabled
        update_styles
      else
        update_styles(:disabled)
      end

      :handled
    end

    def blur(_sender)
      @focus = false

      if @enabled
        update_styles
      else
        update_styles(:disabled)
      end

      :handled
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
      bool = visible?
      @visible = true
      root.gui_state.request_recalculate unless bool
    end

    def hide
      bool = visible?
      @visible = false
      root.gui_state.request_recalculate if bool
    end

    def draw
      return unless visible?

      @style.background_canvas.draw
      @style.background_nine_slice_canvas.draw
      @style.border_canvas.draw

      Gosu.clip_to(@x, @y, width, height) do
        render
      end
    end

    def debug_draw
      return if defined?(GUI_DEBUG_ONLY_ELEMENT) && self.class == GUI_DEBUG_ONLY_ELEMENT

      Gosu.draw_line(
        x, y, @debug_color,
        x + outer_width, y, @debug_color,
        Float::INFINITY
      )
      Gosu.draw_line(
        x + outer_width, y, @debug_color,
        x + outer_width, y + outer_height, @debug_color,
        Float::INFINITY
      )
      Gosu.draw_line(
        x + outer_width, y + outer_height, @debug_color,
        x, y + outer_height, @debug_color,
        Float::INFINITY
      )
      Gosu.draw_line(
        x, outer_height, @debug_color,
        x, y, @debug_color,
        Float::INFINITY
      )
    end

    def update
    end

    def button_down(id)
    end

    def button_up(id)
    end

    def draggable?(_button)
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

    def scroll_width
      @children.sum(&:width) + noncontent_width
    end

    def scroll_height
      @children.sum(&:height) + noncontent_height
    end

    def max_scroll_width
      scroll_width - width
    end

    def max_scroll_height
      scroll_height - height
    end

    def dimensional_size(size, dimension)
      raise "dimension must be either :width or :height" unless %i[width height].include?(dimension)

      if size.is_a?(Numeric) && size.between?(0.0, 1.0)
        (@parent.send(:"content_#{dimension}") * size).round - send(:"noncontent_#{dimension}").round
      else
        size
      end
    end

    def background=(_background)
      @style.background_canvas.background = _background
      update_background
    end

    def update_background
      @style.background_canvas.x = @x
      @style.background_canvas.y = @y
      @style.background_canvas.z = @z
      @style.background_canvas.width  = width
      @style.background_canvas.height = height

      @style.background_canvas.update
      update_background_nine_slice
      @style.border_canvas.update
    end

    def background_nine_slice=(_image_path)
      @style.background_nine_slice_canvas.image = _image_path
      update_background_nine_slice
    end

    def update_background_nine_slice
      @style.background_nine_slice_canvas.x = @x
      @style.background_nine_slice_canvas.y = @y
      @style.background_nine_slice_canvas.z = @z
      @style.background_nine_slice_canvas.width = width
      @style.background_nine_slice_canvas.height = height

      @style.background_nine_slice_canvas.mode = @style.background_nine_slice_mode

      @style.background_nine_slice_canvas.color = @style.background_nine_slice_color

      @style.background_nine_slice_canvas.left   = @style.background_nine_slice_left
      @style.background_nine_slice_canvas.top    = @style.background_nine_slice_top
      @style.background_nine_slice_canvas.right  = @style.background_nine_slice_right
      @style.background_nine_slice_canvas.bottom = @style.background_nine_slice_bottom

      @style.background_nine_slice_canvas.image = @style.background_nine_slice
    end

    def root
      return self if is_root?

      unless @root && @root.parent.nil?
        @root = parent

        loop do
          break unless @root&.parent

          @root = @root.parent
        end
      end

      @root
    end

    def is_root?
      @gui_state != nil
    end

    def focus(_)
      warn "#{self.class}#focus was not overridden!"

      :handled
    end

    def recalculate
      raise "#{self.class}#recalculate was not overridden!"
    end

    def reposition
    end

    def value
      raise "#{self.class}#value was not overridden!"
    end

    def value=(_value)
      raise "#{self.class}#value= was not overridden!"
    end

    def to_s
      "#{self.class} x=#{x} y=#{y} width=#{width} height=#{height} value=#{value.is_a?(String) ? "\"#{value}\"" : value}"
    end

    def inspect
      to_s
    end
  end
end
