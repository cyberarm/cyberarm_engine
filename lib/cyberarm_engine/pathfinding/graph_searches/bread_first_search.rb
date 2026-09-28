module CyberarmEngine
  module Pathfinding
    class BreadthFirstSearch < GraphSearch
      def search(graph:, start:, goal: nil)
        frontier = []
        came_from = {}

        frontier.put(start)
        came_from[start.key] = start

        while(current = frontier.shift)
          # early exit if we reach our goal
          break if current == goal

          graph.neighbors(current).each do |neighbor|
            next if came_from[neighbor.key]

            frontier.put(neighbor)
            came_from[neighbor.key] = current
          end
        end

        came_from
      end
    end
  end
end
