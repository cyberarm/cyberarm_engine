module CyberarmEngine
  module ECS
    class Component
      class Render2D < Component
        TYPE = 0xf0

        attr_reader :image, :scale, :center

        def initialize(image:, scale: CyberarmEngine::Vector.new(1.0, 1.0),
                       center: CyberarmEngine::Vector.new(0.5, 0.5))
          raise "Image must be a Gosu::Image, got #{image.class}" unless image.is_a?(Gosu::Image)
          raise "Scale must be a CyberarmEngine::Vector, got #{scale.class}" unless scale.is_a?(CyberarmEngine::Vector)
          unless center.is_a?(CyberarmEngine::Vector)
            raise "Center must be a CyberarmEngine::Vector, got #{center.class}"
          end

          @image = image
          @scale = scale
          @center = center
        end
      end
    end
  end
end
