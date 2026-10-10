module CyberarmEngine
  module ECS
    class System
      class Render < System
        def truple
          [
            Component::Position,
            Component::Render
          ]
        end

        def draw(entity_store); end
      end
    end
  end
end
