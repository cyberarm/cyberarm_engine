module CyberarmEngine
  class BackgroundNineSlice
    include CyberarmEngine::Common
    attr_accessor :x, :y, :z, :width, :height

    def initialize(image_path:, x: 0, y: 0, z: 0, width: 64, height: 64, left: 4, top: 4, right: 56, bottom: 56)
      @image = get_image(image_path)

      @x = x
      @y = y
      @z = z

      @width = width
      @height = height

      @left = left
      @top = top
      @right = right
      @bottom = bottom

      nine_slice
    end

    def nine_slice
      @segment_top_left = Gosu.render(@left, @top) { @image.draw(0, 0, 0) }
      @segment_top_right = Gosu.render(@image.width - @right, @top) { @image.draw(-@right, 0, 0) }

      @segment_left = Gosu.render(@left, @bottom - @top) { @image.draw(0, -@top, 0) }
      @segment_right = Gosu.render(@image.width - @right, @bottom - @top) { @image.draw(-@right, -@top, 0) }

      @segment_bottom_left = Gosu.render(@left, @image.height - @bottom) { @image.draw(0, -@bottom, 0) }
      @segment_bottom_right = Gosu.render(@image.width - @right, @image.height - @bottom) { @image.draw(-@right, -@bottom, 0) }

      @segment_top = Gosu.render(@right - @left, @top) { @image.draw(-@left, 0, 0) }
      @segment_bottom = Gosu.render(@right - @left, @image.height - @bottom) { @image.draw(-@left, -@bottom, 0) }

      @segment_middle = Gosu.render(@right - @left, @bottom - @top) { @image.draw(-@left, -@top, 0) }
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
      width_scale = (@width - (@left + (@image.width - @right))).to_f / (@right - @left)
    end

    def height_scale
      height_scale = (@height - (@top + (@image.height - @bottom))).to_f / (@bottom - @top)
    end

    def draw
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
  end
end
