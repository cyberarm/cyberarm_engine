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

          @key = format(KEY_FORMAT, @x, @y, @z).freeze

          @edge_nodes = []
        end

        def add_edge_node(node)
          index = @edge_nodes.find_index { |n| n.key == node.key }

          return if index

          @edge_nodes.push(node)
        end

        def remove_edge_node(node)
          index = @edge_nodes.find_index { |n| n.key == node.key }

          return unless index

          @edge_nodes.delete(index)
        end

        def inspect
          format "#<%<class>s:%<id>#018x @key=%<key>s @cost=%<cost>s @edge_nodes=%<edge_nodes>s>",
                 class: self.class,
                 id: object_id << 1,
                 key: key.inspect,
                 cost: cost.inspect,
                 edge_nodes: edge_nodes.map { |n| n&.key }
        end
      end

      def initialize(nodes: {})
        @nodes = nodes
      end

      def node(key)
        @nodes[key]
      end

      def node_at(x, y, z = 0)
        key = format(Node::KEY_FORMAT, x, y, z)
        @nodes[key]
      end

      def neighbors(node)
        node.edge_nodes
      end
    end
  end
end
