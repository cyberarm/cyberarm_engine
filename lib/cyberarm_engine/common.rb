module CyberarmEngine
  module Common
    def push_state(klass, options={})
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

    def show_cursor=boolean
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
        return Gosu::Color.rgba(color.red + amount, color.green + amount, color.blue + amount, color.alpha)
      else
        return Gosu::Color.rgb(color.red + amount, color.green + amount, color.blue + amount)
      end
    end

    def darken(color, amount = 25)
      if defined?(color.alpha)
        return Gosu::Color.rgba(color.red - amount, color.green - amount, color.blue - amount, color.alpha)
      else
        return Gosu::Color.rgb(color.red - amount, color.green - amount, color.blue - amount)
      end
    end

    def opacity(color, ratio = 1.0)
      alpha = 255 * ratio

      return Gosu::Color.rgba(color.red, color.green, color.blue, alpha)
    end

    def get_asset(path, hash, klass)
      asset = nil
      hash.detect do |_asset, instance|
        if _asset == path
          asset = instance
          true
        end
      end

      unless asset
        instance = klass.new(path)
        hash[path] = instance
        asset = instance
      end

      return asset
    end

    def get_image(path)
      get_asset(path, Engine::IMAGES, Gosu::Image)
    end

    def get_sample(path)
      get_asset(path, Engine::SAMPLES, Gosu::Sample)
    end

    def get_song(path)
      get_asset(path, Engine::SONGS, Gosu::Song)
    end

    def window
      $window
    end
  end
end
