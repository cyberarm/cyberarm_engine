module CyberarmEngine
  module Common
    def push_state(klass, options = {})
      window.push_state(klass, options)
    end

    def current_state
      window.current_state
    end

    def previous_state
      window.previous_state
    end

    def pop_state
      window.pop_state
    end

    def show_cursor
      window.show_cursor
    end

    def show_cursor=(boolean)
      window.show_cursor = boolean
    end

    def draw_rect(x, y, width, height, color, z = 0)
      Gosu.draw_rect(x, y, width, height, color, z)
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
      $window
    end
  end
end
