module CyberarmEngine
  class BackgroundImage
    include CyberarmEngine::Common
    attr_accessor :x, :y, :z, :mode
    attr_reader :image, :width, :height, :color

    def initialize(image_path: nil, x: 0, y: 0, z: 0, width: 0, height: 0, mode: :fill, color: Gosu::Color::WHITE)
      @image_path = image_path
      @image = get_image(image_path) if image_path

      @x = x
      @y = y
      @z = z
      @width = width
      @height = height

      @mode = mode

      @color = color

      @cached_tiling = nil
    end

    def image=(image_path)
      @cached_tiling = nil if image_path != @image_path
      @image_path = image_path
      @image = image_path ? get_image(image_path) : image_path
    end

    def width=(n)
      @cached_tiling = nil if @width != n
      @width = n
    end

    def height=(n)
      @cached_tiling = nil if @height != n
      @height = n
    end

    def color=(c)
      @cached_tiling = nil if @color != c
      @color = c
    end

    def width_scale
      (@width.to_f / @image.width).abs
    end

    def height_scale
      (@height.to_f / @image.height).abs
    end

    def draw
      return unless @image

      Gosu.clip_to(@x, @y, @width, @height) do
        send(:"draw_#{mode}")
      end
    end

    def draw_stretch
      @image.draw(@x, @y, @z, width_scale, height_scale, @color)
    end

    def draw_tiled
      @cached_tiling ||= Gosu.record(@width, @height) do
        height_scale.ceil.times do |y|
          width_scale.ceil.times do |x|
            @image.draw(x * @image.width, y * @image.height, @z, 1, 1, @color)
          end
        end
      end

      @cached_tiling.draw(@x, @y, @z)
    end

    def draw_fill
      if (@image.width * width_scale) >= @width && (@image.height * width_scale) >= @height
        draw_fill_width
      else
        draw_fill_height
      end
    end

    def draw_fill_width
      @image.draw(@x, @y, @z, width_scale, width_scale, @color)
    end

    def draw_fill_height
      @image.draw(@x, @y, @z, height_scale, height_scale, @color)
    end
  end
end
