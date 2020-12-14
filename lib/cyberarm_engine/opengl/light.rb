module CyberarmEngine
  class Light
    DIRECTIONAL = 0
    POINT = 1
    SPOT = 2

    attr_reader :light_id
    attr_accessor :type, :ambient, :diffuse, :specular, :position, :direction, :intensity

    def initialize(
      id:,
      type: Light::POINT,
      ambient: Vector.new(0.5, 0.5, 0.5),
      diffuse: Vector.new(1, 1, 1),
      specular: Vector.new(0.2, 0.2, 0.2),
      position: Vector.new(0, 0, 0),
      direction: Vector.new(0, 0, 0),
      intensity: 1
    )
      @light_id = id
      @type = type

      @ambient  = ambient
      @diffuse  = diffuse
      @specular = specular
      @position = position
      @direction = direction

      @intensity = intensity
    end

    def draw
      glLightfv(@light_id, GL_AMBIENT, convert(@ambient).pack("f*"))
      glLightfv(@light_id, GL_DIFFUSE, convert(@diffuse, true).pack("f*"))
      glLightfv(@light_id, GL_SPECULAR, convert(@specular, true).pack("f*"))
      glLightfv(@light_id, GL_POSITION, convert(@position).pack("f*"))
      glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER, 1)
      glEnable(GL_LIGHTING)
      glEnable(@light_id)
    end

    def convert(struct, apply_intensity = false)
      if apply_intensity
        struct.to_a.compact.map { |i| i * @intensity }
      else
        struct.to_a.compact
      end
    end
  end
end
