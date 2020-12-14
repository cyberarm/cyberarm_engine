module CyberarmEngine
  class WavefrontParser < Model::Parser
    def self.handles
      [:obj]
    end

    def parse
      lines = 0
      list = File.read(@model.file_path).split("\n")
      list.each do |line|
        lines += 1
        line = line.strip

        array = line.split(" ")
        case array[0]
        when "mtllib"
          @model.material_file = array[1]
          parse_mtllib
        when "usemtl"
          set_material(array[1])
        when "o"
          change_object(nil, array[1])
        when "s"
          set_smoothing(array[1])
        when "v"
          add_vertex(array)
        when "vt"
          add_texture_coordinate(array)

        when "vn"
          add_normal(array)

        when "f"
          verts = []
          uvs   = []
          norms = []
          array[1..3].each do |f|
            verts << f.split("/")[0]
            uvs   << f.split("/")[1]
            norms << f.split("/")[2]
          end

          face = Face.new
          face.vertices = []
          face.uvs      = []
          face.normals  = []
          face.colors   = []
          face.material = current_material
          face.smoothing = @model.smoothing

          mat   = face.material.diffuse
          color = mat

          verts.each_with_index do |v, index|
            if uvs.first != ""
              face.vertices << @model.vertices[Integer(v) - 1]
              face.uvs      << @model.uvs[Integer(uvs[index]) - 1]
              face.normals  << @model.normals[Integer(norms[index]) - 1]
              face.colors   << color
            else
              face.vertices << @model.vertices[Integer(v) - 1]
              face.uvs      << nil
              face.normals  << @model.normals[Integer(norms[index]) - 1]
              face.colors   << color
            end
          end

          @model.current_object.faces << face
          @model.faces << face
        end
      end

      @model.calculate_bounding_box(@model.vertices, @model.bounding_box)
      @model.objects.each do |o|
        @model.calculate_bounding_box(o.vertices, o.bounding_box)
      end
    end

    def parse_mtllib
      file = File.open(@model.file_path.sub(File.basename(@model.file_path), "") + @model.material_file, "r")
      file.readlines.each do |line|
        array = line.strip.split(" ")
        case array.first
        when "newmtl"
          material = Model::Material.new(array.last)
          @model.current_material = array.last
          @model.materials[array.last] = material
        when "Ns" # Specular Exponent
        when "Ka" # Ambient color
          @model.materials[@model.current_material].ambient  = Color.new(Float(array[1]), Float(array[2]),
                                                                         Float(array[3]))
        when "Kd" # Diffuse color
          @model.materials[@model.current_material].diffuse  = Color.new(Float(array[1]), Float(array[2]),
                                                                         Float(array[3]))
        when "Ks" # Specular color
          @model.materials[@model.current_material].specular = Color.new(Float(array[1]), Float(array[2]),
                                                                         Float(array[3]))
        when "Ke" # Emissive
        when "Ni" # Unknown (Blender Specific?)
        when "d"  # Dissolved (Transparency)
        when "illum" # Illumination model
        when "map_Kd" # Diffuse texture
          texture = File.basename(array[1])
          texture_path = "#{File.expand_path('../../', @model.file_path)}/textures/#{texture}"
          @model.materials[@model.current_material].set_texture(texture_path)
        end
      end
    end

    def set_smoothing(value)
      @model.smoothing = value == "1"
    end

    def add_vertex(array)
      @model.vertex_count += 1
      vert = nil
      if array.size == 5
        vert = Vector.new(Float(array[1]), Float(array[2]), Float(array[3]), Float(array[4]))
      elsif array.size == 4
        vert = Vector.new(Float(array[1]), Float(array[2]), Float(array[3]), 1.0)
      else
        raise
      end
      @model.current_object.vertices << vert
      @model.vertices << vert
    end

    def add_normal(array)
      vert = nil
      if array.size == 5
        vert = Vector.new(Float(array[1]), Float(array[2]), Float(array[3]), Float(array[4]))
      elsif array.size == 4
        vert = Vector.new(Float(array[1]), Float(array[2]), Float(array[3]), 1.0)
      else
        raise
      end
      @model.current_object.normals << vert
      @model.normals << vert
    end

    def add_texture_coordinate(array)
      texture = nil
      if array.size == 4
        texture = Vector.new(Float(array[1]), 1 - Float(array[2]), Float(array[3]))
      elsif array.size == 3
        texture = Vector.new(Float(array[1]), 1 - Float(array[2]), 1.0)
      else
        raise
      end
      @model.uvs << texture
      @model.current_object.uvs << texture
    end
  end
end
