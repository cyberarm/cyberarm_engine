module CyberarmEngine
  module Common
    def push_state(klass, options={})
      $window.push_state(klass, options)
    end

    def current_state
      $window.current_state
    end

    def previous_state
      $window.previous_state
    end

    def pop_state
      $window.pop_state
    end

    def show_cursor
      $window.show_cursor
    end

    def show_cursor=boolean
      $window.show_cursor = boolean
    end

    def draw_rect(x, y, width, height, color, z = 0)
      $window.draw_rect(x,y,width,height,color,z)
    end

    def window
      $window
    end
  end
end