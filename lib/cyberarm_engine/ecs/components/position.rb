module CyberarmEngine
  module ECS
    class Component
      class Position < Component
        TYPE = 0x00

        attr_reader :position

        def initialize(position:)
          unless position.is_a?(CyberarmEngine::Vector)
            raise "Position must be a CyberarmEngine::Vector, got #{position.class}"
          end

          @position = position
        end
      end
    end
  end
end
