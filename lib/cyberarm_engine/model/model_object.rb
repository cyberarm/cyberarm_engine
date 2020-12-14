module CyberarmEngine
  class Model
    class ModelObject
      attr_reader :id, :name, :vertices, :uvs, :normals, :materials, :bounding_box, :debug_color
      attr_accessor :faces, :scale

      def initialize(id, name)
        @id = id
        @name = name
        @vertices = []
        @uvs      = []
        @normals  = []
        @faces    = []
        @materials = []
        @bounding_box = BoundingBox.new
        @debug_color = Color.new(1.0, 1.0, 1.0)

        @scale = 1.0

        # Faces array packs everything:
        #   vertex   = index[0]
        #   uv       = index[1]
        #   normal   = index[2]
        #   material = index[3]
      end

      def has_texture?
        @materials.find { |mat| mat.texture_id } ? true : false
      end

      def reflatten
        @vertices_list = nil
        @uvs_list = nil
        @normals_list = nil

        flattened_vertices
        flattened_uvs
        flattened_normals
      end

      def flattened_vertices
        unless @vertices_list
          @debug_color = @faces.first.material.diffuse

          list = []
          @faces.each do |face|
            face.vertices.each do |v|
              next unless v

              list << v.x * @scale
              list << v.y * @scale
              list << v.z * @scale
              list << v.weight
            end
          end

          @vertices_list_size = list.size
          @vertices_list = list.pack("f*")
        end

        @vertices_list
      end

      def flattened_vertices_size
        @vertices_list_size
      end

      def flattened_uvs
        unless @uvs_list
          list = []
          @faces.each do |face|
            face.uvs.each do |v|
              next unless v

              list << v.x
              list << v.y
              list << v.z
            end
          end

          @uvs_list_size = list.size
          @uvs_list = list.pack("f*")
        end

        @uvs_list
      end

      def flattened_normals
        unless @normals_list
          list = []
          @faces.each do |face|
            face.normals.each do |n|
              next unless n

              list << n.x
              list << n.y
              list << n.z
            end
          end

          @normals_list_size = list.size
          @normals_list = list.pack("f*")
        end

        @normals_list
      end

      def flattened_materials
        unless @materials_list
          list = []
          @faces.each do |face|
            material = face.material
            next unless material

            face.vertices.each do # Add material to each vertex
              list << material.diffuse.red
              list << material.diffuse.green
              list << material.diffuse.blue
              # list << material.alpha
            end
          end

          @materials_list_size = list.size
          @materials_list = list.pack("f*")
        end

        @materials_list
      end
    end
  end
end
