module CyberarmEngine
  module Pathfinding
    class Grid < Graph
      Cell = Data.define(:location, :blocker, :cost)

      # nodes: a 2d array of nodes to convert to list of edges
      def self.edges_from_world_grid(nodes:)
        edges = {}

        nodes.each_index do |y, y_index|
          y.each_with_index do |x_index|
            node = nodes[y_index][x_index]
            next unless node

            left = nodes[y_index]&.[x_index - 1]
            right = nodes[y_index]&.[x_index + 1]
            top = nodes[y_index - 1]&.[x_index]
            bottom = nodes[y_index + 1]&.[x_index]

            location = Location.new(x_index, y_index, 0, 0)
            edges[location] = []
            edges[location].push(Location.new(x_index - 1, y_index, 0, 0)) if left
            edges[location].push(Location.new(x_index + 1, y_index, 0, 0)) if right
            edges[location].push(Location.new(x_index, y_index - 1, 0, 0)) if top
            edges[location].push(Location.new(x_index, y_index + 1, 0, 0)) if bottom
          end
        end

        new(edges: edges)
      end
    end
  end
end
