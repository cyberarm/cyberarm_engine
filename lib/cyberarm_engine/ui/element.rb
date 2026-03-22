module CyberarmEngine
  class Element
    include Theme
    include Event
    include Common

    attr_accessor :x, :y, :z, :tip, :element_visible
    attr_reader :parent, :options, :style, :event_handler, :background_canvas, :border_canvas

    def initialize(options = {}, block = nil)
      @parent = options.delete(:parent) # parent Container (i.e. flow/stack)
      options = theme_defaults(options)
      @options = options
      @block = block

      @focus   = !@options.key?(:focus)   ? false : @options[:focus]
      @enabled = !@options.key?(:enabled) ? true  : @options[:enabled]
      @visible = !@options.key?(:visible) ? true  : @options[:visible]
      @tip     = @options[:tip] || ""

      @debug_color = @options[:debug_color].nil? ? Gosu::Color::RED : @options[:debug_color]

      @style = Style.new(options)

      @root ||= nil
      @gui_state ||= nil
      @element_visible = true

      @x = @style.x
      @y = @style.y
      @z = @style.z

      @old_width  = 0
      @old_height = 0
      @width  = 0
      @height = 0

      @style.width  = default(:width)  || nil
      @style.height = default(:height) || nil

      @background_canvas = Background.new
      @background_nine_slice_canvas = BackgroundNineSlice.new
      @background_image_canvas = BackgroundImage.new
      @border_canvas = BorderCanvas.new(element: self)

      @style_event = :default

      stylize

      default_events

      root.gui_state.request_focus(self) if @options[:autofocus]
    end

    def stylize
      set_static_position

      set_color
      set_font

      set_background
      set_background_nine_slice
      set_background_image

      set_border

      root.gui_state.request_repaint
    end

    def styled(key)
      case key
      when :border_color_bottom, :border_color_left, :border_color_right, :border_color_top
        safe_style_fetch(key, :border_color)
      when :border_thickness_bottom, :border_thickness_left, :border_thickness_right, :border_thickness_top
        safe_style_fetch(key, :border_thickness)
      when :margin_bottom, :margin_left, :margin_right, :margin_top
        safe_style_fetch(key, :margin)
      when :padding_bottom, :padding_left, :padding_right, :padding_top
        safe_style_fetch(key, :padding)
      else
        safe_style_fetch(key)
      end
    end

    def safe_style_fetch(key, fallback_key = nil)
      # Attempt to return value for requested key
      v = @style.send(@style_event)&.send(key) || @style.send(key)
      return v if v

      # Attempt to return overriding value
      if fallback_key
        v = @style.send(@style_event)&.send(fallback_key) || @style.send(fallback_key)
        return v if v
      end

      # Fallback to default style
      @style.hash.dig(:default, key) || default(key)
    end

    def set_static_position
      @x = @style.x if @style.x != 0
      @y = @style.y if @style.y != 0
    end

    def set_color
      @text&.color = safe_style_fetch(:color)
    end

    def set_font
      @text&.swap_font(safe_style_fetch(:text_size), safe_style_fetch(:font))
    end

    def set_background
      @background_canvas.background = safe_style_fetch(:background)
    end

    def set_background_nine_slice
      @background_nine_slice_canvas.x = @x
      @background_nine_slice_canvas.y = @y
      @background_nine_slice_canvas.z = @z
      @background_nine_slice_canvas.width = width
      @background_nine_slice_canvas.height = height

      @background_nine_slice_canvas.mode = safe_style_fetch(:background_nine_slice_mode) || :stretch

      @background_nine_slice_canvas.color = safe_style_fetch(:background_nine_slice_color) || Gosu::Color::WHITE

      @background_nine_slice_canvas.left   = safe_style_fetch(:background_nine_slice_left, :background_nine_slice_from_edge)
      @background_nine_slice_canvas.top    = safe_style_fetch(:background_nine_slice_top, :background_nine_slice_from_edge)
      @background_nine_slice_canvas.right  = safe_style_fetch(:background_nine_slice_right, :background_nine_slice_from_edge)
      @background_nine_slice_canvas.bottom = safe_style_fetch(:background_nine_slice_bottom, :background_nine_slice_from_edge)

      @background_nine_slice_canvas.image = safe_style_fetch(:background_nine_slice)
    end

    def set_background_image
      @background_image_canvas.image = safe_style_fetch(:background_image)
      @background_image_canvas.mode = safe_style_fetch(:background_image_mode) || :stretch
      @background_image_canvas.color = safe_style_fetch(:background_image_color) || Gosu::Color::WHITE
    end

    def set_border
      @border_canvas.color = [
        styled(:border_color_top),
        styled(:border_color_right),
        styled(:border_color_bottom),
        styled(:border_color_left)
      ]
    end

    def update_styles(event = :default)
      old_width = width
      old_height = height

      @style_event = event

      return if self.is_a?(ToolTip)

      root.gui_state.request_recalculate if old_width != width || old_height != height

      stylize
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
      event(:scroll_jump_to_top)
      event(:scroll_jump_to_end)
      event(:scroll_page_up)
      event(:scroll_page_down)

      event(:enter)
      event(:hover)
      event(:leave)

      event(:focus)
      event(:blur)

      event(:changed)
    end

    def enter(_sender)
      @focus = false unless Gosu.button_down?(Gosu::MS_LEFT)

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

    def enabled=(boolean)
      root.gui_state.request_repaint if @enabled != boolean

      @enabled = boolean

      recalculate

      @enabled
    end

    def enabled?
      @enabled
    end

    def focused?
      @focus
    end

    def visible?
      @visible
    end

    def element_visible?
      @element_visible
    end

    def toggle
      @visible = !@visible
      root.gui_state.request_recalculate
      root.gui_state.request_repaint
    end

    def show
      bool = visible?
      @visible = true
      root.gui_state.request_recalculate unless bool
      root.gui_state.request_repaint unless bool
    end

    def hide
      bool = visible?
      @visible = false
      root.gui_state.request_recalculate if bool
      root.gui_state.request_repaint if bool
    end

    def draw
      return unless visible?
      return unless element_visible?

      @background_canvas.draw
      @background_nine_slice_canvas.draw
      @background_image_canvas.draw
      @border_canvas.draw

      render
    end

    def debug_draw
      return if CyberarmEngine.const_defined?("GUI_DEBUG_ONLY_ELEMENT") && self.class == GUI_DEBUG_ONLY_ELEMENT

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
        x, y + outer_height, @debug_color,
        x, y, @debug_color,
        Float::INFINITY
      )
    end

    def update
      recalculate_if_size_changed

      if @style.dirty?
        @style.mark_clean!
        stylize
      end
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
      styled(:margin_left) + width + styled(:margin_right)
    end

    def inner_width
      (styled(:border_thickness_left) + styled(:padding_left)) + (styled(:padding_right) + styled(:border_thickness_right))
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
      styled(:margin_top) + height + styled(:margin_bottom)
    end

    def inner_height
      (styled(:border_thickness_top) + styled(:padding_top)) + (styled(:padding_bottom) + styled(:border_thickness_bottom))
    end

    def scroll_width
      return @cached_scroll_width if @cached_scroll_width && is_a?(Container)

      @cached_scroll_width = @children.sum(&:outer_width)
    end

    def scroll_height
      return @cached_scroll_height if @cached_scroll_height && is_a?(Container)

      if is_a?(CyberarmEngine::Element::Flow)
        return 0 if @children.size.zero?

        pairs_ = []
        sorted_children_ = @children.sort_by(&:y)
        a_ = []
        y_position_ = sorted_children_.first.y

        sorted_children_.each do |child|
          unless child.y == y_position_
            y_position_ = child.y
            pairs_ << a_
            a_ = []
          end

          a_ << child
        end

        pairs_ << a_ unless pairs_.last == a_

        @cached_scroll_height = pairs_.sum { |pair|  + styled(:padding_top) + styled(:border_thickness_top) + pair.map(&:outer_height).max } + styled(:padding_bottom) + styled(:border_thickness_bottom)
      else
        @cached_scroll_height = styled(:padding_top) + styled(:border_thickness_top) + @children.sum(&:outer_height) + styled(:padding_bottom) + styled(:border_thickness_bottom)
      end
    end

    def max_scroll_width
      (scroll_width - outer_width).positive? ? scroll_width - outer_width : scroll_width
    end

    def max_scroll_height
      (scroll_height - outer_height).positive? ? scroll_height - outer_height : scroll_height
    end

    def dimensional_size(size, dimension)
      raise "dimension must be either :width or :height" unless %i[width height].include?(dimension)

      new_size = if size.is_a?(Float) && size.between?(0.0, 1.0)
                   (@parent.send(:"content_#{dimension}") * size).floor - send(:"noncontent_#{dimension}").floor
                 else
                   size
                 end

      # Handle fill behavior
      if @parent && styled(:fill) &&
         (dimension == :width && @parent.is_a?(Flow) ||
          dimension == :height && @parent.is_a?(Stack))
        new_size = space_available_width - noncontent_width if dimension == :width && @parent.is_a?(Flow)
        new_size = space_available_height - noncontent_height if dimension == :height && @parent.is_a?(Stack)
      end

      return styled(:"min_#{dimension}") if styled(:"min_#{dimension}") && new_size.to_f < styled(:"min_#{dimension}")
      return styled(:"max_#{dimension}") if styled(:"max_#{dimension}") && new_size.to_f > styled(:"max_#{dimension}")

      new_size
    end

    def space_available_width
      # TODO: This may get expensive if there are a lot of children, probably should cache it somehow
      fill_siblings = @parent.children.select { |c| c.styled(:fill) }.count.to_f # include self since we're dividing

      available_space = ((@parent.content_width - (@parent.children.reject { |c| c.styled(:fill) }).map(&:outer_width).sum) / fill_siblings)
      (available_space.nan? || available_space.infinite?) ? 0 : available_space.floor # The parent element might not have its dimensions, yet.
    end

    def space_available_height
      # TODO: This may get expensive if there are a lot of children, probably should cache it somehow
      fill_siblings = @parent.children.select { |c| c.styled(:fill) }.count.to_f # include self since we're dividing

      available_space = ((@parent.content_height - (@parent.children.reject { |c| c.styled(:fill) }).map(&:outer_height).sum) / fill_siblings)
      (available_space.nan? || available_space.infinite?) ? 0 : available_space.floor # The parent element might not have its dimensions, yet.
    end

    def background=(_background)
      root.gui_state.request_repaint

      @background_canvas.background = _background
      update_background
    end

    def update_background
      @background_canvas.x = @x
      @background_canvas.y = @y
      @background_canvas.z = @z
      @background_canvas.width  = width
      @background_canvas.height = height

      @background_canvas.update
      set_background_nine_slice
      update_background_image
      @border_canvas.update
    end

    def background_nine_slice=(_image_path)
      root.gui_state.request_repaint

      @background_nine_slice_canvas.image = _image_path
      set_background_nine_slice
    end

    def background_image=(image_path)
      root.gui_state.request_repaint

      @style.background_image = image_path.is_a?(Gosu::Image) ? image_path : get_image(image_path)
      update_background_image
    end

    def update_background_image
      @background_image_canvas.x = @x
      @background_image_canvas.y = @y
      @background_image_canvas.z = @z
      @background_image_canvas.width = width
      @background_image_canvas.height = height

      @background_image_canvas.mode = safe_style_fetch(:background_image_mode) || :stretch
      @background_image_canvas.color = safe_style_fetch(:background_image_color) || Gosu::Color::WHITE

      @background_image_canvas.image = safe_style_fetch(:background_image)
    end

    def recalculate_if_size_changed
      if @parent && !is_a?(ToolTip) && (@old_width != width || @old_height != height)
        root.gui_state.request_recalculate

        @old_width = width
        @old_height = height
      end
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

    def child_of?(element)
      return element == self if is_root?
      return false unless element.is_a?(Container)
      return true if element.children.find { |child| child == self }

      element.children.find { |child| child.child_of?(element) if child.is_a?(Container) }
    end

    def parent_of?(element)
      return false if element == self
      return false unless is_a?(Container)
      return true if @children.find { |child| child == element }

      @children.find { |child| child.parent_of?(element) if child.is_a?(Container) }
    end

    def focus(_)
      warn "#{self.class}#focus was not overridden!"

      :handled
    end

    def recalculate
      old_width = width
      old_height = height

      stylize
      layout

      root.gui_state.request_recalculate if @parent && !is_a?(ToolTip) && (width != old_width || height != old_height)
      root.gui_state.request_repaint if width != old_width || height != old_height

      root.gui_state.menu.recalculate if root.gui_state.menu && root.gui_state.menu.parent == self
    end

    def layout
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
