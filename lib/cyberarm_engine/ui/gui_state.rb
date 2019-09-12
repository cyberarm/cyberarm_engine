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
      @containers     = [@root_container]

      @active_width  = window.width
      @active_height = window.height

      @focus = nil
      @mouse_over = nil
      @mouse_down_on = {}
      @mouse_down_position = {}
      @pending_recalculate_request = false
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

    def update
      if @pending_recalculate_request
        @root_container.recalculate
        @pending_recalculate_request = false
      end

      super

      new_mouse_over = @root_container.hit_element?(window.mouse_x, window.mouse_y)
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

      request_recalculate if @active_width != window.width || @active_height != window.height

      @active_width  = window.width
      @active_height = window.height
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
      end
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
    end

    def redirect_mouse_button(button)
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
      if @mouse_over
        @mouse_over.publish(:"released_#{button}_mouse_button", window.mouse_x, window.mouse_y)
        @mouse_over.publish(:"clicked_#{button}_mouse_button", window.mouse_x, window.mouse_y) if @mouse_over == @mouse_down_on[button]
      end

      @mouse_down_position[button] = nil
      @mouse_down_on[button]       = nil
    end

    def redirect_holding_mouse_button(button)
      @mouse_over.publish(:"holding_#{button}_mouse_button", window.mouse_x, window.mouse_y) if @mouse_over
    end

    def redirect_mouse_wheel(button)
      @mouse_over.publish(:"mouse_wheel_#{button}", window.mouse_x, window.mouse_y) if @mouse_over
    end

    # Schedule a full GUI recalculation on next update
    def request_recalculate
      @pending_recalculate_request = true
    end
  end
end