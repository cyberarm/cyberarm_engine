module CyberarmEngine
  module Pathfinding
    class Grid < Graph

      def add_node(x:, y:, z: 0, cost: 0, replace: false)
        key = format(Node::KEY_FORMAT, x, y, z)
        node = @node[key]

        raise "Node at: #{key} already exists! (#{node})" if node && !replace

        node = Node.new(x: x, y: y, z: z, cost: cost)
        @nodes[key] = node

        update_node_edge_nodes(node)
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

        if remove_node
          [left, right, top, bottom, front, back].remove_edge_node(node)
        else
          [left, right, top, bottom, front, back].add_edge_node(node)
        end
      end
    end
  end
end
