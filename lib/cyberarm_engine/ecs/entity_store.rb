module CyberarmEngine
  module ECS
    class EntityStore
      MAX_ENTITY_ID = 4_294_967_295

      def initialize
        @current_entity_id = -1
        @entities = []

        @systems = [
          System::Movement,
          System::Render2D
        ]
      end

      def create_entity(components)
        ent = Entity.new(id: next_entity_id)

        components.each do |component|
          ent.add_component(component)
        end

        @entities << ent

        ent
      end

      def find_entity(id)
        @entities.find { |e| e.id == id }
      end

      def entities_with(components)
        @entities.select { |e| e.components(components) }
      end

      def remove_entity(entity)
        @entities.delete_if { |e| e == entity }
      end

      def remove_entities(entities)
        @entities.delete_if { |e| entities.include?(e) }
      end

      def remove_all_entities
        @entities.clear
      end

      def next_entity_id
        # NOTE: we'll be sending entity IDs as uint32's (4 bytes with MAX value of MAX_ENTITY_ID [4.29 billion])
        raise "Next entity ID exceeds maximium value!" if @current_entity_id + 1 > MAX_ENTITY_ID

        @current_entity_id += 1
      end
    end
  end
end
