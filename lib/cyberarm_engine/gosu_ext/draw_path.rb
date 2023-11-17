module Gosu
  PathNode = Struct.new(:x, :y)

  def self.draw_path(nodes, color = Gosu::Color::WHITE, z = 0, mode = :default)
    last_node = nodes.first

    nodes[1..nodes.size - 1].each do |current_node|
      Gosu.draw_line(
        last_node.x, last_node.y, color,
        current_node.x, current_node.y, color,
        z, mode
      )

      last_node = current_node
    end
  end
end
