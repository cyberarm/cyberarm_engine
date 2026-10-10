module CyberarmEngine
  module ECS
    class System
      class Movement < System
        def truple
          [
            Component::Position,
            Component::Velocity
          ]
        end

        def update(entity_store); end

        def fixed_update(entity_store); end
      end
    end
  end
end
