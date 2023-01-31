module CyberarmEngine
  module Common
    def push_state(klass, options = {})
      window.push_state(klass, options)
    end

    def current_state
      window.current_state
    end

    def previous_state(state = nil)
      raise "Only available for CyberarmEngine::GameState and subclasses" unless is_a?(CyberarmEngine::GameState) || state.is_a?(CyberarmEngine::GameState)

      i = window.states.index(state || self)
      window.states[i - 1] unless (i - 1).negative?
    end

    def pop_state
      window.pop_state
    end

    def shift_state
      window.shift_state
    end

    def show_cursor
      window.show_cursor
    end

    def show_cursor=(boolean)
      window.show_cursor = boolean
    end

    def find_element_by_tag(container, tag, list = [])
      return unless container

      container.children.each do |child|
        list << child if child.style.tag == tag

        find_element_by_tag(child, tag, list) if child.is_a?(CyberarmEngine::Element::Container)
      end

      list.first
    end

    def draw_rect(x, y, width, height, color, z = 0, mode = :default)
      Gosu.draw_rect(x, y, width, height, color, z, mode)
    end

    def fill(color, z = 0)
      draw_rect(0, 0, window.width, window.height, color, z)
    end

    def lighten(color, amount = 25)
      if defined?(color.alpha)
        Gosu::Color.rgba(color.red + amount, color.green + amount, color.blue + amount, color.alpha)
      else
        Gosu::Color.rgb(color.red + amount, color.green + amount, color.blue + amount)
      end
    end

    def darken(color, amount = 25)
      if defined?(color.alpha)
        Gosu::Color.rgba(color.red - amount, color.green - amount, color.blue - amount, color.alpha)
      else
        Gosu::Color.rgb(color.red - amount, color.green - amount, color.blue - amount)
      end
    end

    def opacity(color, ratio = 1.0)
      alpha = 255 * ratio

      Gosu::Color.rgba(color.red, color.green, color.blue, alpha)
    end

    def get_asset(path, hash, klass, retro = false, tileable = false)
      asset = nil
      hash.detect do |_asset, instance|
        if _asset == path
          asset = instance
          true
        end
      end

      unless asset
        instance = nil
        instance = if klass == Gosu::Image
                     klass.new(path, retro: retro, tileable: tileable)
                   else
                     klass.new(path)
                   end

        hash[path] = instance
        asset = instance
      end

      asset
    end

    def get_image(path, retro: false, tileable: false)
      get_asset(path, Window::IMAGES, Gosu::Image, retro, tileable)
    end

    def get_sample(path)
      get_asset(path, Window::SAMPLES, Gosu::Sample)
    end

    def get_song(path)
      get_asset(path, Window::SONGS, Gosu::Song)
    end

    def window
      CyberarmEngine::Window.instance
    end

    def control_down?
      Gosu.button_down?(Gosu::KB_LEFT_CONTROL) || Gosu.button_down?(Gosu::KB_RIGHT_CONTROL)
    end

    def shift_down?
      Gosu.button_down?(Gosu::KB_LEFT_SHIFT) || Gosu.button_down?(Gosu::KB_RIGHT_SHIFT)
    end

    def alt_down?
      Gosu.button_down?(Gosu::KB_LEFT_ALT) || Gosu.button_down?(Gosu::KB_RIGHT_ALT)
    end
  end
end
