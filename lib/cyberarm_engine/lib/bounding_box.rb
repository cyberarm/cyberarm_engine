module CyberarmEngine
  class BoundingBox
    attr_accessor :min, :max

    def initialize(*args)
      case args.size
      when 0
        @min = Vector.new(0, 0, 0)
        @max = Vector.new(0, 0, 0)
      when 2
        @min = args.first.clone
        @max = args.last.clone
      when 4
        @min = Vector.new(args[0], args[1], 0)
        @max = Vector.new(args[2], args[3], 0)
      when 6
        @min = Vector.new(args[0], args[1], args[2])
        @max = Vector.new(args[3], args[4], args[5])
      else
        raise "Invalid number of arguments! Got: #{args.size}, expected: 0, 2, 4, or 6."
      end
    end

    def ==(other)
      @min == other.min &&
      @max == other.max
    end

    # returns a new bounding box that includes both bounding boxes
    def union(other)
      temp = BoundingBox.new
      temp.min.x = [@min.x, other.min.x].min
      temp.min.y = [@min.y, other.min.y].min
      temp.min.z = [@min.z, other.min.z].min

      temp.max.x = [@max.x, other.max.x].max
      temp.max.y = [@max.y, other.max.y].max
      temp.max.z = [@max.z, other.max.z].max

      return temp
    end

    # returns the difference between both bounding boxes
    def difference(other)
      temp = BoundingBox.new
      temp.min = @min - other.min
      temp.max = @max - other.max

      return temp
    end

    # returns whether both bounding boxes intersect
    def intersect?(other)
      (@min.x <= other.max.x && @max.x >= other.min.x) &&
      (@min.y <= other.max.y && @max.y >= other.min.y) &&
      (@min.z <= other.max.z && @max.z >= other.min.z)
    end

    # does this bounding box envelop other bounding box? (inclusive of border)
    def contains?(other)
      other.min.x >= min.x && other.min.y >= min.y && other.min.z >= min.z &&
      other.max.x <= max.x && other.max.y <= max.y && other.max.z <= max.z
    end

    # returns whether the vector is inside of the bounding box
    def point?(vector)
      vector.x.between?(@min.x, @max.x) &&
      vector.y.between?(@min.y, @max.y) &&
      vector.z.between?(@min.z, @max.z)
    end

    def volume
      width * height * depth
    end

    def width
      @max.x - @min.x
    end

    def height
      @max.y - @min.y
    end

    def depth
      @max.z - @min.z
    end

    def normalize(entity)
      temp = BoundingBox.new
      temp.min.x = @min.x.to_f * entity.scale
      temp.min.y = @min.y.to_f * entity.scale
      temp.min.z = @min.z.to_f * entity.scale

      temp.max.x = @max.x.to_f * entity.scale
      temp.max.y = @max.y.to_f * entity.scale
      temp.max.z = @max.z.to_f * entity.scale

      return temp
    end

    def normalize_with_offset(entity)
      temp = BoundingBox.new
      temp.min.x = @min.x.to_f * entity.scale + entity.position.x
      temp.min.y = @min.y.to_f * entity.scale + entity.position.y
      temp.min.z = @min.z.to_f * entity.scale + entity.position.z

      temp.max.x = @max.x.to_f * entity.scale + entity.position.x
      temp.max.y = @max.y.to_f * entity.scale + entity.position.y
      temp.max.z = @max.z.to_f * entity.scale + entity.position.z

      return temp
    end

    def +(other)
      box = BoundingBox.new
      box.min = self.min + other.min
      box.min = self.max + other.max

      return box
    end

    def -(other)
      box = BoundingBox.new
      box.min = self.min - other.min
      box.min = self.max - other.max

      return box
    end

    def sum
      @min.sum + @max.sum
    end

    def clone
      BoundingBox.new(@min.x, @min.y, @min.z, @max.x, @max.y, @max.z)
    end
  end
end