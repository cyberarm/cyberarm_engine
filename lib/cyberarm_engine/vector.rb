module CyberarmEngine
  class Vector
    def self.up
      Vector.new(0, 1, 0)
    end

    def self.down
      Vector.new(0, -1, 0)
    end

    def self.left
      Vector.new(-1, 0, 0)
    end

    def self.right
      Vector.new(1, 0, 0)
    end

    def self.forward
      Vector.new(0, 0, 1)
    end

    def self.backward
      Vector.new(0, 0, -1)
    end

    def initialize(x = 0, y = 0, z = 0, weight = 0)
      @x, @y, @z, @weight = x, y, z, weight
    end

    def x; @x; end
    def x=(n); @x = n; end

    def y; @y; end
    def y=(n); @y = n; end

    def z; @z; end
    def z=(n); @z = n; end

    def weight; @weight; end
    def weight=(n); @weight = n; end

    alias w weight
    alias w= weight=

    def ==(other)
      if other.is_a?(Numeric)
        @x      == other &&
        @y      == other &&
        @z      == other &&
        @weight == other
      else
        @x      == other.x &&
        @y      == other.y &&
        @z      == other.z &&
        @weight == other.weight
      end
    end

    # Performs math operation, excluding @weight
    private def operator(function, other)
      if other.is_a?(Numeric)
        Vector.new(
          @x.send(:"#{function}", other),
          @y.send(:"#{function}", other),
          @z.send(:"#{function}", other)
        )
      else
        Vector.new(
          @x.send(:"#{function}", other.x),
          @y.send(:"#{function}", other.y),
          @z.send(:"#{function}", other.z)
        )
      end
    end

    # Adds Vector and Numberic or Vector and Vector, excluding @weight
    def +(other)
      operator("+", other)
    end

    # Subtracts Vector and Numberic or Vector and Vector, excluding @weight
    def -(other)
      operator("-", other)
    end

    # Multiplies Vector and Numberic or Vector and Vector, excluding @weight
    def *(other)
      operator("*", other)
    end

    # Divides Vector and Numberic or Vector and Vector, excluding @weight
    def /(other)
      # Duplicated to protect from DivideByZero
      if other.is_a?(Numeric)
        Vector.new(
          (@x == 0 ? 0 : @x / other),
          (@y == 0 ? 0 : @y / other),
          (@z == 0 ? 0 : @z / other)
        )
      else
        Vector.new(
          (@x == 0 ? 0 : @x / other.x),
          (@y == 0 ? 0 : @y / other.y),
          (@z == 0 ? 0 : @z / other.z)
        )
      end
    end

    def dot(other)
      product = 0

      a = self.to_a
      b = other.to_a

      3.times do |i|
        product = product + (a[i] * b[i])
      end

      return product
    end

    def cross(other)
      a = self.to_a
      b = other.to_a

      Vector.new(
        b[2] * a[1] - b[1] * a[2],
        b[0] * a[2] - b[2] * a[0],
        b[1] * a[0] - b[0] * a[1]
      )
    end

    # returns degrees
    def angle(other)
      Math.acos( self.normalized.dot(other.normalized) ) * 180 / Math::PI
    end

    # returns magnitude of Vector, ignoring #weight
    def magnitude
      Math.sqrt((@x * @x) + (@y * @y) + (@z * @z))
    end

    def normalized
      mag = magnitude
      self / Vector.new(mag, mag, mag)
    end

    def direction
      # z is pitch
      # y is yaw
      # x is roll
      _x = -Math.sin(@y.degrees_to_radians) * Math.cos(@z.degrees_to_radians)
      _y = Math.sin(@z.degrees_to_radians)
      _z = Math.cos(@y.degrees_to_radians) * Math.cos(@z.degrees_to_radians)

      Vector.new(_x, _y, _z)
    end

    def inverse
      Vector.new(1.0 / @x, 1.0 / @y, 1.0 / @z)
    end

    def sum
      @x + @y + @z
    end

    def lerp(other, factor)
      (self - other) * factor.clamp(0.0, 1.0)
    end

    # 2D distance using X and Y
    def distance(other)
      Math.sqrt((@x-other.x)**2 + (@y-other.y)**2)
    end

    # 2D distance using X and Z
    def gl_distance2d(other)
      Math.sqrt((@x-other.x)**2 + (@z-other.z)**2)
    end

    # 3D distance using X, Y, and Z
    def distance3d(other)
      Math.sqrt((@x-other.x)**2 + (@y-other.y)**2 + (@z-other.z)**2)
    end

    def to_a
      [@x, @y, @z, @weight]
    end

    def to_s
      "X: #{@x}, Y: #{@y}, Z: #{@z}, Weight: #{@weight}"
    end

    def to_h
      {x: @x, y: @y, z: @z, weight: @weight}
    end
  end
end