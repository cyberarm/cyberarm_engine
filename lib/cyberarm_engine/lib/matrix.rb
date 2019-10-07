module CyberarmEngine
  class Matrix
    attr_reader :elements, :rows, :columns
    def initialize(matrix, rows:, columns:)
      @elements = matrix
      @rows = rows
      @columns = columns

      raise "Matrix is wrong size! Got #{@elements.size}, expected #{@rows * @columns}" if @rows * @columns != @elements.size
    end

    def +(other)
    end

    def -(other)
    end

    def *(other)
    end

    def cofactor
    end

    def adjoint
      sign = 1
      matrix = @elements.clone

      @rows.times do |row|
        @columns.times do |columns|
        end
      end
    end

    def determinant
    end

    # https://www.geeksforgeeks.org/adjoint-inverse-matrix/
    def inverse
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

      rotate_matrix = Matrix.new(matrix, rows: 4, columns: 4)

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

      Matrix.new(matrix, rows: 4, columns: 4)
    end

    def self.scale(vector, center_around = nil)
      scale_x, scale_y, scale_z = vector.to_a[0..2]
      matrix = [
        scale_x, 0,       0,       0,
        0,       scale_y, 0,       0,
        0,       0,       scale_z, 0,
        0,       0,       0,       1,
      ]

      scale_matrix = Matrix.new(matrix, rows: 4, columns: 4)

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
      rows = left.rows

      matrix.size.times do |i|
        matrix[i] = 0

        rows.times do |j|
          matrix[i] += left.elements[i / rows * rows + j] * right.elements[i % rows + j * rows]
        end
      end

      Matrix.new(matrix, rows: 4, columns: 4)
    end
  end
end