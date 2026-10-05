module CyberarmEngine
  module Pathfinding
    class Grid < Graph
      def add_node(x:, y:, z: 0, cost: 0, replace: false)
        key = format(Node::KEY_FORMAT, x, y, z)
        node = @nodes[key]

        raise "Node at: #{key} already exists! (#{node})" if node && !replace

        node = Node.new(x: x, y: y, z: z, cost: cost)
        @nodes[key] = node

        update_node_edge_nodes(node)
        node
      end

      def remove_node(node)
        update_node_edge_nodes(node, remove_node: true)

        @nodes.delete(node.key)
      end

      def update_node_edge_nodes(node, remove_node: false)
        x = node.x
        y = node.y
        z = node.z

        # add node to neighbors
        # 2D
        left = @nodes[format(Node::KEY_FORMAT, x - 1, y, z)]
        right = @nodes[format(Node::KEY_FORMAT, x + 1, y, z)]
        top = @nodes[format(Node::KEY_FORMAT, x, y - 1, z)]
        bottom = @nodes[format(Node::KEY_FORMAT, x, y + 1, z)]
        # 3D
        front = @nodes[format(Node::KEY_FORMAT, x, y, z - 1)]
        back = @nodes[format(Node::KEY_FORMAT, x, y, z + 1)]

        possible_edge_nodes = [left, right, top, bottom, front, back]

        if remove_node
          possible_edge_nodes.each { |n| n&.remove_edge_node(node) }
        else
          possible_edge_nodes.each { |n| n&.add_edge_node(node) }
        end
      end

      def update_edge_nodes
        @nodes.each { |k, n| update_node_edge_nodes(n) }
      end
    end
  end
end
