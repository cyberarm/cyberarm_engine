module CyberarmEngine
  # Basic 4x4 matrix operations
  class Transform
    attr_reader :elements

    def initialize(matrix)
      @elements = matrix

      raise "Transform is wrong size! Got #{@elements.size}, expected 16" if 16 != @elements.size
      raise "Invalid value for matrix, must all be numeric!" if @elements.any? { |e| e.nil? || !e.is_a?(Numeric) }
    end

    def self.identity
      Transform.new(
        [
          1, 0, 0, 0,
          0, 1, 0, 0,
          0, 0, 1, 0,
          0, 0, 0, 1
        ]
      )
    end

    ### 2D Operations meant for interacting with Gosu ###

    # 2d rotate operation, replicates Gosu's Gosu.rotate function
    def self.rotate(angle, rotate_around = nil)
      double c = Math.cos(angle).degrees_to_radians
      double s = Math.sin(angle).degrees_to_radians
      matrix = [
        +c, +s, 0, 0,
        -s, +c, 0, 0,
        0,  0,  1, 0,
        0,  0,  0, 1
      ]

      rotate_matrix = Transform.new(matrix, rows: 4, columns: 4)

      if rotate_around && (rotate_around.x != 0.0 || rotate_around.y != 0.0)
        negative_rotate_around = Vector.new(-rotate_around.x, -rotate_around.y, -rotate_around.z)

        rotate_matrix = concat(
          concat(translate(negative_rotate_around), rotate_matrix),
          translate(rotate_around)
        )
      end

      rotate_matrix
    end

    # 2d translate operation, replicates Gosu's Gosu.translate function
    def self.translate(vector)
      x, y, z = vector.to_a[0..2]
      matrix = [
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        x, y, z, 1
      ]

      Transform.new(matrix)
    end

    # 2d scale operation, replicates Gosu's Gosu.rotate function
    def self.scale(vector, center_around = nil)
      scale_x, scale_y, scale_z = vector.to_a[0..2]
      matrix = [
        scale_x, 0,       0,       0,
        0,       scale_y, 0,       0,
        0,       0,       scale_z, 0,
        0,       0,       0,       1
      ]

      scale_matrix = Transform.new(matrix)

      if center_around && (center_around.x != 0.0 || center_around.y != 0.0)
        negative_center_around = Vector.new(-center_around.x, -center_around.y, -center_around.z)

        scale_matrix = concat(
          concat(translate(negative_center_around), scale_matrix),
          translate(center_around)
        )
      end

      scale_matrix
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

    #### 3D Operations meant for OpenGL ###

    def self.translate_3d(vector)
      x, y, z = vector.to_a[0..2]
      matrix = [
        1, 0, 0, x,
        0, 1, 0, y,
        0, 0, 1, z,
        0, 0, 0, 1
      ]

      Transform.new(matrix)
    end

    def self.rotate_3d(vector, _order = "zyx")
      x, y, z = vector.to_a[0..2].map { |axis| axis * Math::PI / 180.0 }

      rotation_x = Transform.new(
        [
          1, 0,           0,            0,
          0, Math.cos(x), -Math.sin(x), 0,
          0, Math.sin(x), Math.cos(x),  0,
          0, 0,           0,            1
        ]
      )

      rotation_y = Transform.new(
        [
          Math.cos(y),  0, Math.sin(y), 0,
          0,            1, 0,           0,
          -Math.sin(y), 0, Math.cos(y), 0,
          0,            0, 0,           1
        ]
      )

      rotation_z = Transform.new(
        [
          Math.cos(z), -Math.sin(z), 0, 0,
          Math.sin(z), Math.cos(z),  0, 0,
          0,           0,            1, 0,
          0,           0,            0, 1
        ]
      )

      rotation_z * rotation_y * rotation_x
    end

    # Implements glRotatef
    # https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glRotate.xml
    def self.rotate_gl(angle, axis)
      radians = angle * Math::PI / 180.0
      s = Math.sin(radians)
      c = Math.cos(radians)

      axis = axis.normalized
      x, y, z = axis.to_a[0..2]

      n = (1.0 - c)

      Transform.new(
        [
          x * x * n + c,     x * y * n - z * s, x * z * n + y * s, 0,
          y * x * n + z * s, y * y * n + c,     y * z * n - x * s, 0,
          x * z * n - y * s, y * z * n + x * s, z * z * n + c,     0,
          0,                 0,                 0, 1.0
        ]
      )
    end

    def self.scale_3d(vector)
      x, y, z = vector.to_a[0..2]

      Transform.new(
        [
          x, 0, 0, 0,
          0, y, 0, 0,
          0, 0, z, 0,
          0, 0, 0, 1
        ]
      )
    end

    def self.perspective(fov_y, aspect_ratio, near, far)
      f = 1.0 / Math.tan(fov_y.degrees_to_radians / 2.0) # cotangent
      zn = (far + near.to_f) / (near - far.to_f)
      zf = (2.0 * far * near.to_f) / (near - far.to_f)

      Transform.new(
        [
          f / aspect_ratio, 0.0,    0.0, 0.0,
          0.0,                f,    0.0, 0.0,
          0.0,                0.0, zn, zf,
          0.0,                0.0, -1.0, 0.0
        ]
      )
    end

    def self.orthographic(left, right, bottom, top, near, far)
      s = Vector.new(
        2 / (right - left.to_f),
        2 / (top - bottom.to_f),
        -2 / (far - near.to_f)
      )

      t = Vector.new(
        (right + left.to_f)   / (right - left.to_f),
        (top   + bottom.to_f) / (top   - bottom.to_f),
        (far   + near.to_f)   / (far   - near.to_f)
      )

      Transform.new(
        [
          s.x, 0.0, 0.0, t.x,
          0.0, s.y, 0.0, t.y,
          0.0, 0.0, s.z, t.z,
          0.0, 0.0, 0.0, 1.0
        ]
      )
    end

    def self.view(eye, orientation)
      # https://www.3dgep.com/understanding-the-view-matrix/#The_View_Matrix
      cosPitch = Math.cos(orientation.z * Math::PI / 180.0)
      sinPitch = Math.sin(orientation.z * Math::PI / 180.0)
      cosYaw = Math.cos(orientation.y * Math::PI / 180.0)
      sinYaw = Math.sin(orientation.y * Math::PI / 180.0)

      x_axis = Vector.new(cosYaw, 0, -sinYaw)
      y_axis = Vector.new(sinYaw * sinPitch, cosPitch, cosYaw * sinPitch)
      z_axis = Vector.new(sinYaw * cosPitch, -sinPitch, cosPitch * cosYaw)

      Transform.new(
        [
          x_axis.x, y_axis.y, z_axis.z, 0,
          x_axis.x,         y_axis.y,         z_axis.z, 0,
          x_axis.x,         y_axis.y,         z_axis.z, 0,
          -x_axis.dot(eye), -y_axis.dot(eye), -z_axis.dot(eye), 1
        ]
      )
    end

    def *(other)
      case other
      when CyberarmEngine::Vector
        matrix = @elements.clone
        list = other.to_a

        @elements.each_with_index do |e, i|
          matrix[i] = e + list[i % 4]
        end

        Transform.new(matrix)

      when CyberarmEngine::Transform
        multiply_matrices(other)
      else
        p other.class
        raise TypeError, "Expected CyberarmEngine::Vector or CyberarmEngine::Transform got #{other.class}"
      end
    end

    def get(x, y)
      width = 4

      # puts "Transform|#{self.object_id} -> #{@elements[width * y + x].inspect} (index: #{width * y + x})"
      @elements[width * y + x]
    end

    def multiply_matrices(other)
      matrix = Array.new(16, 0)

      4.times do |x|
        4.times do |y|
          4.times do |k|
            matrix[4 * y + x] += get(x, k) * other.get(k, y)
          end
        end
      end

      Transform.new(matrix)
    end

    # arranges Matrix in column major form
    def to_gl
      e = @elements
      [
        e[0], e[4], e[8],  e[12],
        e[1], e[5], e[9],  e[13],
        e[2], e[6], e[10], e[14],
        e[3], e[7], e[11], e[15]
      ]
    end
  end
end
