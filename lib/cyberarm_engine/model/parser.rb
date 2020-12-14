module CyberarmEngine
  TextureCoordinate = Struct.new(:u, :v, :weight)
  Point = Struct.new(:x, :y)
  Color = Struct.new(:red, :green, :blue, :alpha)
  Face  = Struct.new(:vertices, :uvs, :normals, :colors, :material, :smoothing)

  class Model
    class Parser
      @@parsers = []

      def self.handles
        raise NotImplementedError,
              "Model::Parser#handles must return an array of file extensions that this parser supports"
      end

      def self.inherited(parser)
        @@parsers << parser
      end

      def self.find(file_type)
        @@parsers.find do |parser|
          parser.handles.include?(file_type)
        end
      end

      def self.supported_formats
        @@parsers.map { |parser| parser.handles }.flatten.map { |s| ".#{s}" }.join(", ")
      end

      def initialize(model)
        @model = model
      end

      def parse
      end

      def set_object(id: nil, name: nil)
        _model = nil

        if id
          _model = @model.objects.find { |o| o.id == id }
        elsif name
          _model = @model.objects.find { |o| o.name == name }
        else
          raise "Must provide either an id: or name:"
        end

        if _model
          @model.current_object = _model
        else
          raise "Couldn't find ModelObject!"
        end
      end

      def change_object(id, name)
        @model.objects << Model::ModelObject.new(id, name)
        @model.current_object = @model.objects.last
      end

      def set_material(name)
        @model.current_material = name
        @model.current_object.materials << current_material
      end

      def add_material(name, material)
        @model.materials[name] = material
      end

      def current_material
        @model.materials[@model.current_material]
      end
    end
  end
end
