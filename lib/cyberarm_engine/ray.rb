module CyberarmEngine
  class Ray
    def initialize(origin, direction, range = Float::INFINITY)
      raise "Origin must be a Vector!" unless origin.is_a?(Vector)
      raise "Direction must be a Vector!" unless direction.is_a?(Vector)

      @origin = origin
      @direction = direction
      @range = range

      @inverse_direction = @direction.inverse
    end

    def intersect?(intersectable)
      if intersectable.is_a?(BoundingBox)
        intersect_bounding_box?(intersectable)
      else
        raise NotImplementedError, "Ray intersection test for #{intersectable.class} not implemented."
      end
    end

    # Based on: https://tavianator.com/fast-branchless-raybounding-box-intersections/
    def intersect_bounding_box?(box)
      tmin = -@range
      tmax = @range

      tx1 = (box.min.x - @origin.x) * @inverse_direction.x
      tx2 = (box.max.x - @origin.x) * @inverse_direction.x

      tmin = max(tmin, min(tx1, tx2))
      tmax = min(tmax, max(tx1, tx2))

      ty1 = (box.min.y - @origin.y) * @inverse_direction.y
      ty2 = (box.max.y - @origin.y) * @inverse_direction.y

      tmin = max(tmin, min(ty1, ty2))
      tmax = min(tmax, max(ty1, ty2))

      tz1 = (box.min.z - @origin.z) * @inverse_direction.z
      tz2 = (box.max.z - @origin.z) * @inverse_direction.z

      tmin = max(tmin, min(tz1, tz2))
      tmax = min(tmax, max(tz1, tz2))

      tmax >= max(tmin, 0.0)
    end

    def min(x, y)
      ((x) < (y) ? x : y)
    end

    def max(x, y)
      ((x) > (y) ? x : y)
    end
  end
end
