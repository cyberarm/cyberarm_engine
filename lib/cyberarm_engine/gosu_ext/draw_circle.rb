module Gosu
  ##
  # Draw a filled circled around point X and Y.
  #
  # @param x X position.
  # @param y Y position.
  # @param radius radius of circle, in pixels.
  # @param step_size resolution of circle, more steps will apear smoother, less will appear jagged.
  # @param color color to draw circle with.
  # @param mode blend mode.
  #
  # @return [void]
  def self.draw_circle(x, y, radius, step_size = 36, color = Gosu::Color::WHITE, z = 0, mode = :default)
    step_size = (360.0 / step_size).floor

    0.step(359, step_size) do |angle|
      angle2 = angle + step_size

      point_lx = x + Gosu.offset_x(angle, radius)
      point_ly = y + Gosu.offset_y(angle, radius)
      point_rx = x + Gosu.offset_x(angle2, radius)
      point_ry = y + Gosu.offset_y(angle2, radius)

      Gosu.draw_triangle(
        point_lx, point_ly, color,
	      point_rx, point_ry, color,
	      x, y, color, z, mode
      )
    end
  end
end