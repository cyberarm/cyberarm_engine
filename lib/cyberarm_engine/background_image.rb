module CyberarmEngine
  class BackgroundImage
    include CyberarmEngine::Common
    attr_accessor :x, :y, :z, :width, :height, :mode, :color
    attr_reader :image

    def initialize(image_path: nil, x: 0, y: 0, z: 0, width: 0, height: 0, mode: :fill, color: Gosu::Color::WHITE)
      @image = get_image(image_path) if image_path

      @x = x
      @y = y
      @z = z
      @width = width
      @height = height

      @mode = mode

      @color = color
    end

    def image=(image_path)
      @image = image_path ? get_image(image_path) : image_path
    end

    def width_scale
      (@width.to_f / @image.width).abs
    end

    def height_scale
      (@height.to_f / @image.height).abs
    end

    def draw
      return unless @image

      send(:"draw_#{mode}")
    end

    def draw_stretch
      @image.draw(@x, @y, @z, width_scale, height_scale, @color)
    end

    def draw_tiled
      raise NotImplementedError
    end

    def draw_fill
      if @width * width_scale > height * height_scale
        @image.draw(@x, @y, @z, width_scale, width_scale, @color)
      else
        @image.draw(@x, @y, @z, height_scale, height_scale, @color)
      end
    end
  end
end
