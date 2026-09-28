module CyberarmEngine
  module Pathfinding
    class Graph
      Location = Data.define(:x, :y, :z, :cost)

      def initialize(edges: {})
        @edges = edges
      end

      def neighbors(location)
        @edges[location]
      end
    end
  end
end
