module CyberarmEngine
  class Vector

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

    # def xy=(nx, ny); @x = nx; @y = ny; end
    # def xyz=(nx, ny, nz); @x = nx; @y = ny; @z = nz; end
    # def xyzw=(nx, ny, nz, nw); @x = nx; @y = ny; @z = nz; @weight = nw; end

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

    def +(other)
      Vector.new(
        @x      + other.x,
        @y      + other.y,
        @z      + other.z,
        @weight + other.weight
      )
    end

    def -(other)
      Vector.new(
        @x      - other.x,
        @y      - other.y,
        @z      - other.z,
        @weight - other.weight
      )
    end

    def *(other)
      Vector.new(
        @x      * other.x,
        @y      * other.y,
        @z      * other.z,
        @weight * other.weight
        )
      end

    def /(other)
      # Endeavors to prevent division by zero
      Vector.new(
        @x      == 0 || other.x      == 0 ? 0 : @x      / other.x,
        @y      == 0 || other.y      == 0 ? 0 : @y      / other.y,
        @z      == 0 || other.z      == 0 ? 0 : @z      / other.z,
        @weight == 0 || other.weight == 0 ? 0 : @weight / other.weight
      )
    end

    # returns magnitude of Vector, ignoring #weight
    def magnitude
      Math.sqrt((@x * @x) + (@y * @y) + (@z * @z))
    end

    def normalized
      mag = magnitude
      self / Vector.new(mag, mag, mag)
    end

    def sum
      @x + @y + @z + @weight
    end

    def to_a
      [@x, @y, @z, @weight]
    end

    def to_s
      "X: #{@x}, Y: #{@y}, Z: #{@z}, Weight: #{@weight}"
    end
  end
end