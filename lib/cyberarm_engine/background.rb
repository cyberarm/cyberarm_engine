module CyberarmEngine
  class Background
    attr_accessor :x, :y, :z, :width, :height, :angle, :debug
    attr_reader   :background

    def initialize(x: 0, y: 0, z: 0, width: 0, height: 0, background: Gosu::Color::BLACK, angle: 0, debug: false)
      @x = x
      @y = y
      @z = z
      @width = width
      @height = height
      @debug = debug

      @paint  = Paint.new(background)
      @angle  = angle

      @top_left     = Vector.new(@x, @y)
      @top_right    = Vector.new(@x + @width, @y)
      @bottom_left  = Vector.new(@x, @y + @height)
      @bottom_right = Vector.new(@x + @width, @y + @height)
    end

    def draw
      Gosu.clip_to(@x, @y, @width, @height) do
        Gosu.draw_quad(
          @top_left.x,     @top_left.y,     @paint.top_left,
          @top_right.x,    @top_right.y,    @paint.top_right,
          @bottom_right.x, @bottom_right.y, @paint.bottom_right,
          @bottom_left.x,  @bottom_left.y,  @paint.bottom_left,
          @z
        )
      end

      debug_outline if @debug
    end

    def update
      origin_x = (@x + (@width / 2))
      origin_y = (@y + (@height / 2))

      points = [
        @top_left     = Vector.new(@x, @y),
        @top_right    = Vector.new(@x + @width, @y),
        @bottom_left  = Vector.new(@x, @y + @height),
        @bottom_right = Vector.new(@x + @width, @y + @height)
      ]

      [@top_left, @top_right, @bottom_left, @bottom_right].each do |vector|
        temp_x = vector.x - origin_x
        temp_y = vector.y - origin_y

        # 90 is up here, while gosu uses 0 for up.
        radians = (@angle + 90).gosu_to_radians
        vector.x = (@x + (@width / 2))  + ((temp_x * Math.cos(radians)) - (temp_y * Math.sin(radians)))
        vector.y = (@y + (@height / 2)) + ((temp_x * Math.sin(radians)) + (temp_y * Math.cos(radians)))
      end

      # [
      #   [:top,    @top_left, @top_right],
      #   [:right,  @top_right, @bottom_right],
      #   [:bottom, @bottom_right, @bottom_left],
      #   [:left,   @bottom_left, @top_left]
      # ].each do |edge|
      #   points.each do |point|
      #     puts "#{edge.first} -> #{shortest_distance(point, edge[1], edge[2])}"
      #   end
      # end
    end

    def shortest_distance(point, la, lb)
      a = la.x - lb.x
      b = la.y - lb.y
      c = Gosu.distance(la.x, la.y, lb.x, lb.y)
      p a, b, c
      d = (a * point.x + b * point.y + c).abs / Math.sqrt(a * a + b * b)
      puts "Distance: #{d}"
      exit!
      d
    end

    def debug_outline
      # Top
      Gosu.draw_line(
        @x,          @y,           Gosu::Color::RED,
        @x + @width, @y,           Gosu::Color::RED,
        @z
      )

      # Right
      Gosu.draw_line(
        @x + @width, @y,           Gosu::Color::RED,
        @x + @width, @y + @height, Gosu::Color::RED,
        @z
      )

      # Bottom
      Gosu.draw_line(
        @x + @width, @y + @height, Gosu::Color::RED,
        @x, @y + @height,          Gosu::Color::RED,
        @z
      )

      # Left
      Gosu.draw_line(
        @x, @y + @height,          Gosu::Color::RED,
        @x, @y,                    Gosu::Color::RED,
        @z
      )
    end

    def background=(_background)
      @paint.set(_background)
      update
    end

    def angle=(n)
      @angle = n
      update
    end
  end

  class Paint
    attr_accessor :top_left, :top_right, :bottom_left, :bottom_right

    def initialize(background)
      set(background)
    end

    def set(background)
      @background = background

      if background.is_a?(Numeric)
        @top_left     = background
        @top_right    = background
        @bottom_left  = background
        @bottom_right = background
      elsif background.is_a?(Gosu::Color)
        @top_left     = background
        @top_right    = background
        @bottom_left  = background
        @bottom_right = background
      elsif background.is_a?(Array)
        if background.size == 1
          set(background.first)
        elsif background.size == 2
          @top_left     = background.first
          @top_right    = background.last
          @bottom_left  = background.first
          @bottom_right = background.last
        elsif background.size == 4
          @top_left     = background[0]
          @top_right    = background[1]
          @bottom_left  = background[2]
          @bottom_right = background[3]
        else
          raise ArgumentError, "background array was empty or had wrong number of elements (expected 2 or 4 elements)"
        end
      elsif background.is_a?(Hash)
        @top_left     = background[:top_left]
        @top_right    = background[:top_right]
        @bottom_left  = background[:bottom_left]
        @bottom_right = background[:bottom_right]
      elsif background.is_a?(Range)
        set([background.begin, background.begin, background.end, background.end])
      else
        raise ArgumentError, "background '#{background}' of type '#{background.class}' was not able to be processed"
      end
    end
  end
end

# Add <=> method to support Range based gradients
module Gosu
  class Color
    def <=>(_other)
      self
    end
  end
end
