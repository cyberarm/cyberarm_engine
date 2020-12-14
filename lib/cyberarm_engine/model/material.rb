module CyberarmEngine
  class Model
    class Material
      attr_accessor :name, :ambient, :diffuse, :specular
      attr_reader :texture_id

      def initialize(name)
        @name    = name
        @ambient = Color.new(1, 1, 1, 1)
        @diffuse = Color.new(1, 1, 1, 1)
        @specular = Color.new(1, 1, 1, 1)
        @texture = nil
        @texture_id = nil
      end

      def set_texture(texture_path)
        @texture_id = Texture.new(path: texture_path).id
      end
    end
  end
end
