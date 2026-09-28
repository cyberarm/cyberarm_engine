module CyberarmEngine
  module Pathfinding
    class BreadthFirstSearch < GraphSearch
      def search(graph:, start:, goal: nil)
        frontier = []
        came_from = {}

        frontier.put(start)
        came_from[start] = start

        while(current = frontier.shift)
          # early exit if we reach our goal
          break if current == goal

          graph.neighbors(current).each do |neighbor|
            next if came_from[neighbor]

            frontier.put(neighbor)
            came_from[neighbor] = current
          end
        end

        came_from
      end
    end
  end
end
