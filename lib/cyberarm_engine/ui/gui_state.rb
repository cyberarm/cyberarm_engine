module CyberarmEngine
  class GuiState < GameState
    include Common
    include DSL

    def initialize(options = {})
      @options = options
      @game_objects = []
      @global_pause = false

      @root_container = Stack.new
      @game_objects << @root_container
      @containers     = [@root_container]

      @focus = nil
      @mouse_over = nil
      @mouse_down_on = {}
      @mouse_down_position = {}


      setup
    end

    def focus=(element)
      @focus.publish(:blur) if @focus and element
      @focus = element
    end

    def update
      super

      new_mouse_over = @root_container.hit_element?(window.mouse_x, window.mouse_y)
      if new_mouse_over
        new_mouse_over.publish(:enter) if new_mouse_over != @mouse_over
        new_mouse_over.publish(:hover, window.mouse_x, window.mouse_y)
      end
      @mouse_over.publish(:leave) if @mouse_over && new_mouse_over != @mouse_over
      @mouse_over = new_mouse_over

      redirect_holding_mouse_button(:left) if @mouse_over && Gosu.button_down?(Gosu::MsLeft)
      redirect_holding_mouse_button(:middle) if @mouse_over && Gosu.button_down?(Gosu::MsMiddle)
      redirect_holding_mouse_button(:right) if @mouse_over && Gosu.button_down?(Gosu::MsRight)
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
      @mouse_over.publish(:"#{button}_mouse_button", window.mouse_x, window.mouse_y) if @mouse_over
    end

    def redirect_released_mouse_button(button)
      @mouse_over.publish(:"released_#{button}_mouse_button", window.mouse_x, window.mouse_y) if @mouse_over
    end

    def redirect_holding_mouse_button(button)
      @mouse_over.publish(:"holding_#{button}_mouse_button", window.mouse_x, window.mouse_y) if @mouse_over
    end

    def redirect_mouse_wheel(button)
      @mouse_over.publish(:"mouse_wheel_#{button}", window.mouse_x, window.mouse_y) if @mouse_over
    end
  end
end