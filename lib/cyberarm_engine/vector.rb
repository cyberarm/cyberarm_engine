module CyberarmEngine
  class Vector
    ##
    # Creates a up vector
    #
    #   Vector.new(0, 1, 0)
    #
    # @return [CyberarmEngine::Vector]
    def self.up
      Vector.new(0, 1, 0)
    end

    ##
    # Creates a down vector
    #
    #   Vector.new(0, -1, 0)
    #
    # @return [CyberarmEngine::Vector]
    def self.down
      Vector.new(0, -1, 0)
    end

    ##
    # Creates a left vector
    #
    #   Vector.new(-1, 0, 0)
    #
    # @return [CyberarmEngine::Vector]
    def self.left
      Vector.new(-1, 0, 0)
    end

    ##
    # Creates a right vector
    #
    #   Vector.new(1, 0, 0)
    #
    # @return [CyberarmEngine::Vector]
    def self.right
      Vector.new(1, 0, 0)
    end

    ##
    # Creates a forward vector
    #
    #   Vector.new(0, 0, 1)
    #
    # @return [CyberarmEngine::Vector]
    def self.forward
      Vector.new(0, 0, 1)
    end

    ##
    # Creates a backward vector
    #
    #   Vector.new(0, 0, -1)
    #
    # @return [CyberarmEngine::Vector]
    def self.backward
      Vector.new(0, 0, -1)
    end

    attr_accessor :x, :y, :z, :weight

    def initialize(x = 0, y = 0, z = 0, weight = 0)
      @x = x
      @y = y
      @z = z
      @weight = weight
    end

    alias w weight
    alias w= weight=

    # @return [Boolean]
    def ==(other)
      if other.is_a?(Numeric)
        @x      == other &&
          @y      == other &&
          @z      == other &&
          @weight == other
      elsif other.is_a?(Vector)
        @x      == other.x &&
          @y      == other.y &&
          @z      == other.z &&
          @weight == other.weight
      else
        other == self
      end
    end

    # Create a new vector using {x} and {y} values
    # @return [CyberarmEngine::Vector]
    def xy
      Vector.new(@x, @y)
    end

    # Performs math operation, excluding {weight}
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

    # Adds Vector and Numeric or Vector and Vector, excluding {weight}
    # @return [CyberarmEngine::Vector]
    def +(other)
      operator("+", other)
    end

    # Subtracts Vector and Numeric or Vector and Vector, excluding {weight}
    # @return [CyberarmEngine::Vector]
    def -(other)
      operator("-", other)
    end

    # Multiplies Vector and Numeric or Vector and Vector, excluding {weight}
    # @return [CyberarmEngine::Vector]
    def *(other)
      operator("*", other)
    end

    def multiply_transform(transform)
      e = transform.elements

      x = @x * e[0]  + @y * e[1]  + @z * e[2]  + 1 * e[3]
      y = @x * e[4]  + @y * e[5]  + @z * e[6]  + 1 * e[7]
      z = @x * e[8]  + @y * e[9]  + @z * e[10] + 1 * e[11]
      w = @x * e[12] + @y * e[13] + @z * e[14] + 1 * e[15]

      Vector.new(x / 1, y / 1, z / 1, w / 1)
    end

    # Divides Vector and Numeric or Vector and Vector, excluding {weight}
    # @return [CyberarmEngine::Vector]
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

    # dot product of {Vector}
    # @return [Integer|Float]
    def dot(other)
      product = 0

      a = to_a
      b = other.to_a

      3.times do |i|
        product += (a[i] * b[i])
      end

      product
    end

    # cross product of {Vector}
    # @return [CyberarmEngine::Vector]
    def cross(other)
      a = to_a
      b = other.to_a

      Vector.new(
        b[2] * a[1] - b[1] * a[2],
        b[0] * a[2] - b[2] * a[0],
        b[1] * a[0] - b[0] * a[1]
      )
    end

    # returns degrees
    # @return [Float]
    def angle(other)
      Math.acos(normalized.dot(other.normalized)) * 180 / Math::PI
    end

    # returns magnitude of Vector, ignoring #weight
    # @return [Float]
    def magnitude
      Math.sqrt((@x * @x) + (@y * @y) + (@z * @z))
    end

    ##
    # returns normalized {Vector}
    #
    # @example
    #   CyberarmEngine::Vector.new(50, 21.2, 45).normalized
    #   # => <CyberarmEngine::Vector:0x001 @x=0.7089... @y=0.3005... @z=0.6380... @weight=0>
    #
    # @return [CyberarmEngine::Vector]
    def normalized
      mag = magnitude
      self / Vector.new(mag, mag, mag)
    end

    # returns a direction {Vector}
    #
    # z is pitch
    #
    # y is yaw
    #
    # x is roll
    # @return [CyberarmEngine::Vector]
    def direction
      _x = -Math.sin(@y.degrees_to_radians) * Math.cos(@z.degrees_to_radians)
      _y = Math.sin(@z.degrees_to_radians)
      _z = Math.cos(@y.degrees_to_radians) * Math.cos(@z.degrees_to_radians)

      Vector.new(_x, _y, _z)
    end

    # returns an inverse {Vector}
    # @return [CyberarmEngine::Vector]
    def inverse
      Vector.new(1.0 / @x, 1.0 / @y, 1.0 / @z)
    end

    # Adds up values of {x}, {y}, and {z}
    # @return [Integer|Float]
    def sum
      @x + @y + @z
    end

    ##
    # Linear interpolation: smoothly transition between two {Vector}
    #
    #   CyberarmEngine::Vector.new(100, 100, 100).lerp( CyberarmEngine::Vector.new(0, 0, 0), 0.75 )
    #   # => <CyberarmEngine::Vector:0x0001 @x=75.0, @y=75.0, @z=75.0, @weight=0>
    #
    # @param other [CyberarmEngine::Vector | Integer | Float] value to subtract from
    # @param factor [Float] how complete transition to _other_ is, in range [0.0..1.0]
    # @return [CyberarmEngine::Vector]
    def lerp(other, factor)
      (self - other) * factor.clamp(0.0, 1.0)
    end

    # 2D distance using X and Y
    # @return [Float]
    def distance(other)
      Math.sqrt((@x - other.x)**2 + (@y - other.y)**2)
    end

    # 2D distance using X and Z
    # @return [Float]
    def gl_distance2d(other)
      Math.sqrt((@x - other.x)**2 + (@z - other.z)**2)
    end

    # 3D distance using X, Y, and Z
    # @return [Float]
    def distance3d(other)
      Math.sqrt((@x - other.x)**2 + (@y - other.y)**2 + (@z - other.z)**2)
    end

    # Converts {Vector} to Array
    # @return [Array]
    def to_a
      [@x, @y, @z, @weight]
    end

    # Converts {Vector} to String
    # @return [String]
    def to_s
      "X: #{@x}, Y: #{@y}, Z: #{@z}, Weight: #{@weight}"
    end

    # Converts {Vector} to Hash
    # @return [Hash]
    def to_h
      { x: @x, y: @y, z: @z, weight: @weight }
    end
  end
end
