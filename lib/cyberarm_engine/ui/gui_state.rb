module CyberarmEngine
  class GuiState < GameState
    include Common
    include DSL

    def initialize(options = {})
      @options = options
      @game_objects = []
      @global_pause = false

      @down_keys = {}

      @root_container = Element::Stack.new(gui_state: self)
      @game_objects << @root_container
      $__current_container__ = @root_container

      @active_width  = window.width
      @active_height = window.height

      @menu = nil
      @focus = nil
      @mouse_over = nil
      @mouse_down_on = {}
      @mouse_down_position = {}
      @last_mouse_pos = nil
      @dragging_element = nil
      @pending_recalculate_request = false

      @tip = CyberarmEngine::Text.new("", size: 22, z: Float::INFINITY)
      @menu = nil
      @min_drag_distance = 0
      @mouse_pos = Vector.new
    end

    # throws :blur event to focused element and sets GuiState focused element
    # Does NOT throw :focus event at element or set element as focused
    def focus=(element)
      @focus.publish(:blur) if @focus and element && @focus != element
      @focus = element
    end

    def focused
      @focus
    end

    def draw
      super

      if @menu
        Gosu.flush
        @menu.draw
      end

      if @tip.text.length > 0
        Gosu.draw_rect(@tip.x - 2, @tip.y - 2, @tip.width + 4, @tip.height + 4, 0xff020202, Float::INFINITY)
        @tip.draw
      end
    end

    def update
      if @pending_recalculate_request
        @root_container.recalculate
        @root_container.recalculate
        @root_container.recalculate

        @pending_recalculate_request = false
      end

      @menu.update if @menu
      super

      new_mouse_over = @menu.hit_element?(window.mouse_x, window.mouse_y) if @menu
      new_mouse_over = @root_container.hit_element?(window.mouse_x, window.mouse_y) unless new_mouse_over

      if new_mouse_over
        new_mouse_over.publish(:enter) if new_mouse_over != @mouse_over
        new_mouse_over.publish(:hover)
        # puts "#{new_mouse_over.class}[#{new_mouse_over.value}]: #{new_mouse_over.x}:#{new_mouse_over.y} #{new_mouse_over.width}:#{new_mouse_over.height}" if new_mouse_over != @mouse_over
      end
      @mouse_over.publish(:leave) if @mouse_over && new_mouse_over != @mouse_over
      @mouse_over = new_mouse_over

      redirect_holding_mouse_button(:left) if @mouse_over && Gosu.button_down?(Gosu::MsLeft)
      redirect_holding_mouse_button(:middle) if @mouse_over && Gosu.button_down?(Gosu::MsMiddle)
      redirect_holding_mouse_button(:right) if @mouse_over && Gosu.button_down?(Gosu::MsRight)

      if Vector.new(window.mouse_x, window.mouse_y) == @last_mouse_pos
        if @mouse_over && (Gosu.milliseconds - @mouse_moved_at) > tool_tip_delay
          @tip.text = @mouse_over.tip if @mouse_over
          @tip.x, @tip.y = window.mouse_x - @tip.width / 2, window.mouse_y - @tip.height - 4
        else
          @tip.text = ""
        end
      else
        @mouse_moved_at = Gosu.milliseconds
      end

      @last_mouse_pos = Vector.new(window.mouse_x, window.mouse_y)
      @mouse_pos = @last_mouse_pos.clone

      request_recalculate if @active_width != window.width || @active_height != window.height

      @active_width  = window.width
      @active_height = window.height
    end

    def tool_tip_delay
      500 # ms
    end

    def button_down(id)
      super

      case id
      when Gosu::MsLeft
        redirect_mouse_button(:left)
      when Gosu::MsMiddle
        redirect_mouse_button(:middle)
      when Gosu::MsRight
        redirect_mouse_button(:right)
      when Gosu::KbF5
        request_recalculate
      end

      @focus.button_down(id) if @focus.respond_to?(:button_down)
    end

    def button_up(id)
      super

      case id
      when Gosu::MsLeft
        redirect_released_mouse_button(:left)
      when Gosu::MsMiddle
        redirect_released_mouse_button(:middle)
      when Gosu::MsRight
        redirect_released_mouse_button(:right)
      when Gosu::MsWheelUp
        redirect_mouse_wheel(:up)
      when Gosu::MsWheelDown
        redirect_mouse_wheel(:down)
      end

      @focus.button_up(id) if @focus.respond_to?(:button_up)
    end

    def redirect_mouse_button(button)
      hide_menu unless @menu and (@menu == @mouse_over) or (@mouse_over&.parent == @menu)

      if @focus && @mouse_over != @focus
        @focus.publish(:blur)
        @focus = nil
      end

      if @mouse_over
        @mouse_down_position[button] = Vector.new(window.mouse_x, window.mouse_y)
        @mouse_down_on[button]       = @mouse_over

        @mouse_over.publish(:"#{button}_mouse_button", window.mouse_x, window.mouse_y)
      else
        @mouse_down_position[button] = nil
        @mouse_down_on[button]       = nil
      end
    end

    def redirect_released_mouse_button(button)
      hide_menu if @menu and (@menu == @mouse_over) or (@mouse_over&.parent == @menu)

      if @mouse_over
        @mouse_over.publish(:"released_#{button}_mouse_button", window.mouse_x, window.mouse_y)
        @mouse_over.publish(:"clicked_#{button}_mouse_button", window.mouse_x, window.mouse_y) if @mouse_over == @mouse_down_on[button]
      end

      if @dragging_element
        @dragging_element.publish(:end_drag, window.mouse_x, window.mouse_y, button)
        @dragging_element = nil
      end

      @mouse_down_position[button] = nil
      @mouse_down_on[button]       = nil
    end

    def redirect_holding_mouse_button(button)
      if !@dragging_element && @mouse_down_on[button] && @mouse_down_on[button].draggable?(button) && @mouse_pos.distance(@mouse_down_position[button]) > @min_drag_distance
        @dragging_element = @mouse_down_on[button]
        @dragging_element.publish(:"begin_drag", window.mouse_x, window.mouse_y, button)
      end

      if @dragging_element
        @dragging_element.publish(:"drag_update", window.mouse_x, window.mouse_y, button) if @dragging_element
      else
        @mouse_over.publish(:"holding_#{button}_mouse_button", window.mouse_x, window.mouse_y) if @mouse_over
      end
    end

    def redirect_mouse_wheel(button)
      @mouse_over.publish(:"mouse_wheel_#{button}", window.mouse_x, window.mouse_y) if @mouse_over
    end

    # Schedule a full GUI recalculation on next update
    def request_recalculate
      @pending_recalculate_request = true
    end

    def show_menu(list_box)
      @menu = list_box
    end

    def hide_menu
      @menu = nil
    end
  end
end