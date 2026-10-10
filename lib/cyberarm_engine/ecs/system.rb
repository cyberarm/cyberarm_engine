module CyberarmEngine
  module ECS
    class System
      # Array of required components for this system
      def truple
        []
      end

      def update(entity); end

      def fixed_update(entity); end
    end
  end
end
