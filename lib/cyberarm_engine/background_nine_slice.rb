module CyberarmEngine
  class BackgroundNineSlice
    include CyberarmEngine::Common
    attr_accessor :x, :y, :z, :width, :height

    def initialize(image_path:, x: 0, y: 0, z: 0, width: 64, height: 64, mode: :tiled, left: 4, top: 4, right: 56, bottom: 56)
      @image = get_image(image_path)

      @x = x
      @y = y
      @z = z

      @width = width
      @height = height

      @mode = mode

      @left = left
      @top = top
      @right = right
      @bottom = bottom

      nine_slice
    end

    def nine_slice
      @segment_top_left = @image.subimage(0, 0, @left, @top)
      @segment_top_right = @image.subimage(@image.width - @right, 0, @right, @top)

      @segment_left = @image.subimage(0, @top, @left, @image.height - (@top + @bottom))
      @segment_right = @image.subimage(@image.width - @right, @top, @left, @image.height - (@top + @bottom))

      @segment_bottom_left = @image.subimage(0, @image.height - @bottom, @left, @bottom)
      @segment_bottom_right = @image.subimage(@image.width - @right, @image.height - @bottom, @right, @bottom)

      @segment_top = @image.subimage(@left, 0, @image.width - (@left + @right), @top)
      @segment_bottom = @image.subimage(@left, @image.height - @bottom, @image.width - (@left + @right), @bottom)

      @segment_middle = @image.subimage(@left, @top, @image.width - (@left + @right), @image.height - (@top + @bottom))
    end

    def cx
      @x + @left
    end

    def cy
      @y + @top
    end

    def cwidth
      @cx - @width
    end

    def cheight
      @cy - @height
    end

    def width_scale
      scale = (@width - (@image.width - (@left + @right))).to_f / (@image.width - (@left + @right))
      scale.abs
    end

    def height_scale
      scale = (@height - (@image.height - (@top + @bottom))).to_f / (@image.height - (@top + @bottom))
      scale.abs
    end

    def draw
      @mode == :tiled ? draw_tiled : draw_stretched
    end

    def draw_stretched
      @segment_top_left.draw(@x, @y, @z)
      @segment_top.draw(@x + @segment_top_left.width, @y, @z, width_scale) # SCALE X
      @segment_top_right.draw((@x + @width) - @segment_top_right.width, @y, @z)

      @segment_right.draw((@x + @width) - @segment_right.width, @y + @top, @z, 1, height_scale) # SCALE Y
      @segment_bottom_right.draw((@x + @width) - @segment_bottom_right.width, @y + @height - @segment_bottom_right.height, @z)
      @segment_bottom.draw(@x + @segment_bottom_left.width, (@y + @height) - @segment_bottom.height, @z, width_scale) # SCALE X
      @segment_bottom_left.draw(@x, (@y + @height) - @segment_bottom_left.height, @z)
      @segment_left.draw(@x, @y + @top, @z, 1, height_scale) # SCALE Y
      @segment_middle.draw(@x + @segment_top_left.width, @y + @segment_top.height, @z, width_scale, height_scale) # SCALE X and SCALE Y
    end

    def draw_tiled
      @segment_top_left.draw(@x, @y, @z)

      p [width_scale, height_scale]

      Gosu.clip_to(@x + @segment_top_left.width, @y, @segment_top.width * width_scale, @segment_top.height) do
        width_scale.ceil.times do |i|
          @segment_top.draw(@x + @segment_top_left.width + (@segment_top.width * i), @y, @z) # SCALE X
        end
      end

      @segment_top_right.draw((@x + @width) - @segment_top_right.width, @y, @z)

      Gosu.clip_to(@x + @width - @segment_top_right.width, @y + @top, @segment_right.width, @segment_right.height * height_scale) do
        height_scale.ceil.times do |i|
          @segment_right.draw((@x + @width) - @segment_right.width, @y + @top + (@segment_right.height * i), @z) # SCALE Y
        end
      end

      @segment_bottom_right.draw((@x + @width) - @segment_bottom_right.width, @y + @height - @segment_bottom_right.height, @z)

      Gosu.clip_to(@x + @segment_top_left.width, @y + @height - @segment_bottom.height, @segment_top.width * width_scale, @segment_bottom.height) do
        width_scale.ceil.times do |i|
          @segment_bottom.draw(@x + @segment_bottom_left.width + (@segment_bottom.width * i), (@y + @height) - @segment_bottom.height, @z) # SCALE X
        end
      end

      @segment_bottom_left.draw(@x, (@y + @height) - @segment_bottom_left.height, @z)

      Gosu.clip_to(@x, @y + @top, @segment_left.width, @segment_left.height * height_scale) do
        height_scale.ceil.times do |i|
          @segment_left.draw(@x, @y + @top + (@segment_left.height * i), @z) # SCALE Y
        end
      end

      Gosu.clip_to(@x + @segment_top_left.width, @y + @segment_top.height, @width - (@segment_left.width + @segment_right.width), @height - (@segment_top.height + @segment_bottom.height)) do
        height_scale.ceil.times do |y|
          width_scale.ceil.times do |x|
            @segment_middle.draw(@x + @segment_top_left.width + (@segment_middle.width * x), @y + @segment_top.height + (@segment_middle.height * y), @z) # SCALE X and SCALE Y
          end
        end
      end
    end
  end
end
