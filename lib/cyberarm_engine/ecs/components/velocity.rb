module CyberarmEngine
  module ECS
    class Component
      class Velocity < Component
        TYPE = 0x01

        attr_reader :velocity

        def initialize(velocity:)
          unless velocity.is_a?(CyberarmEngine::Vector)
            raise "Velocity must be a CyberarmEngine::Vector, got #{velocity.class}"
          end

          @velocity = velocity
        end
      end
    end
  end
end
