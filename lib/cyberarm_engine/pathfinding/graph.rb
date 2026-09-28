module CyberarmEngine
  module Pathfinding
    class Graph
      class Node
        KEY_FORMAT = "%s:%s:%s".freeze

        attr_reader :x, :y, :z, :cost, :key, :edge_nodes

        def initialize(x:, y:, z: 0, cost: 0)
          @x = x
          @y = y
          @z = z
          @cost = cost

          @key = format(KEY_FORMAT, @x, @y, @z)

          @edge_nodes = []
        end

        def add_edge_node(node)
          index = @edge_nodes.find_index { |n| n.key == node.key }

          if index
            @edge_nodes[index] = node
          else
            @edge_nodes.push(node)
          end
        end

        def remove_edge_node(node)
          index = @edge_nodes.find_index { |n| n.key == node.key }

          return unless index

          @edge_nodes.delete(index)
        end
      end

      def initialize(nodes: {})
        @nodes = nodes
      end

      def neighbors(node)
        node.edge_nodes
      end
    end
  end
end
