module CyberarmEngine
  class Transform
    attr_reader :elements
    def initialize(matrix)
      @elements = matrix

      raise "Transform is wrong size! Got #{@elements.size}, expected 16" if 16 != @elements.size
    end

    def error(pos)
      p @elements
      Vector.new(@elements[3], @elements[7]) - pos
    end

    def self.rotate(angle, rotate_around = nil)
      double c = Math.cos(angle).degrees_to_radians
      double s = Math.sin(angle).degrees_to_radians
      matrix = [
          +c, +s, 0, 0,
          -s, +c, 0, 0,
          0,  0,  1, 0,
          0,  0,  0, 1,
      ]

      rotate_matrix = Transform.new(matrix, rows: 4, columns: 4)

      if rotate_around && (rotate_around.x != 0.0 || rotate_around.y != 0.0)
        negative_rotate_around = Vector.new(-rotate_around.x, -rotate_around.y, -rotate_around.z)

        rotate_matrix = concat(
          concat(translate(negative_rotate_around), rotate_matrix),
          translate(rotate_around)
        )
      end

      return rotate_matrix
    end

    def self.translate(vector)
      x, y, z = vector.to_a[0..2]
      matrix = [
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        x, y, z, 1,
      ]

      Transform.new(matrix)
    end

    def self.scale(vector, center_around = nil)
      scale_x, scale_y, scale_z = vector.to_a[0..2]
      matrix = [
        scale_x, 0,       0,       0,
        0,       scale_y, 0,       0,
        0,       0,       scale_z, 0,
        0,       0,       0,       1,
      ]

      scale_matrix = Transform.new(matrix)

      if center_around && (center_around.x != 0.0 || center_around.y != 0.0)
        negative_center_around = Vector.new(-center_around.x, -center_around.y, -center_around.z)

        scale_matrix = concat(
          concat(translate(negative_center_around), scale_matrix),
          translate(center_around)
        )
      end

      return scale_matrix
    end

    def self.concat(left, right)
      matrix = Array.new(left.elements.size)
      rows = 4

      matrix.size.times do |i|
        matrix[i] = 0

        rows.times do |j|
          matrix[i] += left.elements[i / rows * rows + j] * right.elements[i % rows + j * rows]
        end
      end

      Transform.new(matrix)
    end
  end
end