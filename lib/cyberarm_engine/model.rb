module CyberarmEngine
  class Model
    attr_accessor :objects, :materials, :vertices, :uvs, :texures, :normals, :faces, :colors, :bones, :material_file,
                  :current_material, :current_object, :vertex_count, :smoothing
    attr_reader :position, :bounding_box, :textured_material, :file_path, :positions_buffer_id, :colors_buffer_id,
                :normals_buffer_id, :uvs_buffer_id, :textures_buffer_id, :vertex_array_id, :aabb_tree,
                :vertices_count

    def initialize(file_path:)
      @file_path = file_path

      @material_file  = nil
      @current_object = nil
      @current_material = nil
      @vertex_count = 0

      @objects = []
      @materials = {}
      @vertices = []
      @colors   = []
      @uvs      = []
      @normals  = []
      @faces    = []
      @bones    = []
      @smoothing = 0

      @vertices_count = 0

      @bounding_box = BoundingBox.new
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)

      type = File.basename(file_path).split(".").last.to_sym
      parser = Model::Parser.find(type)
      raise "Unsupported model type '.#{type}', supported models are: #{Model::Parser.supported_formats}" unless parser

      parse(parser)

      @vertices_count = @vertices.size

      @has_texture = false

      @materials.each do |_key, material|
        @has_texture = true if material.texture_id
      end

      allocate_gl_objects
      populate_vertex_buffer
      configure_vao

      @objects.each { |o| @vertex_count += o.vertices.size }

      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
      # build_collision_tree
    end

    def parse(parser)
      parser.new(self).parse
    end

    def calculate_bounding_box(vertices, bounding_box)
      unless bounding_box.min.x.is_a?(Float)
        vertex = vertices.last
        bounding_box.min.x = vertex.x
        bounding_box.min.y = vertex.y
        bounding_box.min.z = vertex.z

        bounding_box.max.x = vertex.x
        bounding_box.max.y = vertex.y
        bounding_box.max.z = vertex.z
      end

      vertices.each do |vertex|
        bounding_box.min.x = vertex.x if vertex.x <= bounding_box.min.x
        bounding_box.min.y = vertex.y if vertex.y <= bounding_box.min.y
        bounding_box.min.z = vertex.z if vertex.z <= bounding_box.min.z

        bounding_box.max.x = vertex.x if vertex.x >= bounding_box.max.x
        bounding_box.max.y = vertex.y if vertex.y >= bounding_box.max.y
        bounding_box.max.z = vertex.z if vertex.z >= bounding_box.max.z
      end
    end

    def allocate_gl_objects
      # Allocate arrays for future use
      @vertex_array_id = nil
      buffer = " " * 4
      glGenVertexArrays(1, buffer)
      @vertex_array_id = buffer.unpack1("L2")

      # Allocate buffers for future use
      @positions_buffer_id = nil
      buffer = " " * 4
      glGenBuffers(1, buffer)
      @positions_buffer_id = buffer.unpack1("L2")

      @colors_buffer_id = nil
      buffer = " " * 4
      glGenBuffers(1, buffer)
      @colors_buffer_id = buffer.unpack1("L2")

      @normals_buffer_id = nil
      buffer = " " * 4
      glGenBuffers(1, buffer)
      @normals_buffer_id = buffer.unpack1("L2")

      @uvs_buffer_id = nil
      buffer = " " * 4
      glGenBuffers(1, buffer)
      @uvs_buffer_id = buffer.unpack1("L2")
    end

    def populate_vertex_buffer
      pos     = []
      colors  = []
      norms   = []
      uvs     = []

      @faces.each do |face|
        pos     << face.vertices.map { |vert| [vert.x, vert.y, vert.z] }
        colors  << face.colors.map   { |color| [color.red, color.green, color.blue] }
        norms   << face.normals.map  { |vert| [vert.x, vert.y, vert.z, vert.weight] }

        uvs << face.uvs.map { |vert| [vert.x, vert.y, vert.z] } if has_texture?
      end

      glBindBuffer(GL_ARRAY_BUFFER, @positions_buffer_id)
      glBufferData(GL_ARRAY_BUFFER, pos.flatten.size * Fiddle::SIZEOF_FLOAT, pos.flatten.pack("f*"), GL_STATIC_DRAW)

      glBindBuffer(GL_ARRAY_BUFFER, @colors_buffer_id)
      glBufferData(GL_ARRAY_BUFFER, colors.flatten.size * Fiddle::SIZEOF_FLOAT, colors.flatten.pack("f*"),
                   GL_STATIC_DRAW)

      glBindBuffer(GL_ARRAY_BUFFER, @normals_buffer_id)
      glBufferData(GL_ARRAY_BUFFER, norms.flatten.size * Fiddle::SIZEOF_FLOAT, norms.flatten.pack("f*"), GL_STATIC_DRAW)

      if has_texture?
        glBindBuffer(GL_ARRAY_BUFFER, @uvs_buffer_id)
        glBufferData(GL_ARRAY_BUFFER, uvs.flatten.size * Fiddle::SIZEOF_FLOAT, uvs.flatten.pack("f*"), GL_STATIC_DRAW)
      end

      glBindBuffer(GL_ARRAY_BUFFER, 0)
    end

    def configure_vao
      glBindVertexArray(@vertex_array_id)
      gl_error?

      # index, size, type, normalized, stride, pointer
      # vertices (positions)
      glBindBuffer(GL_ARRAY_BUFFER, @positions_buffer_id)
      gl_error?

      #                     inPosition
      glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, nil)
      gl_error?
      # colors
      glBindBuffer(GL_ARRAY_BUFFER, @colors_buffer_id)
      #                     inColor
      glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, nil)
      gl_error?
      # normals
      glBindBuffer(GL_ARRAY_BUFFER, @normals_buffer_id)
      #                     inNormal
      glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, 0, nil)
      gl_error?

      if has_texture?
        # uvs
        glBindBuffer(GL_ARRAY_BUFFER, @uvs_buffer_id)
        #                     inUV
        glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, 0, nil)
        gl_error?
      end

      glBindBuffer(GL_ARRAY_BUFFER, 0)
      glBindVertexArray(0)
    end

    def build_collision_tree
      @aabb_tree = AABBTree.new

      @faces.each do |face|
        box = BoundingBox.new
        box.min = face.vertices.first.dup
        box.max = face.vertices.first.dup

        face.vertices.each do |vertex|
          if vertex.sum < box.min.sum
            box.min = vertex.dup
          elsif vertex.sum > box.max.sum
            box.max = vertex.dup
          end
        end

        # FIXME: Handle negatives
        box.min *= 1.5
        box.max *= 1.5
        @aabb_tree.insert(face, box)
      end
    end

    def has_texture?
      @has_texture
    end

    def release_gl_resources
      if @vertex_array_id

      end
    end
  end
end
