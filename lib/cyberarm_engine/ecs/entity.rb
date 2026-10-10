module CyberarmEngine
  module ECS
    class Entity
      attr_reader :entity_id, :entity_components

      def initialize(id:)
        @entity_id = id
        # there are more cache friendly ways to implement component storage/lookup but right now this is "good enough."
        @entity_components = []
      end

      def add_component(component)
        raise "Component already exists on entity!" if @entity_components.find { |c| c.is_a?(component) }

        @entity_components << component
      end

      def component(component)
        @entity_components.find { |c| c.is_a?(component) }
      end

      def components(components)
        components.each do |c|
          return false unless @entity_components.include? { |comp| c.is_a?(comp) }
        end

        true
      end

      def remove_component(component)
        @entity_components.delete_if { |c| c.is_a?(component) }
      end
    end
  end
end
