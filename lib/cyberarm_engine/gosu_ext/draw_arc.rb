module Gosu
  # Draw an arc around the point x and y.
  #
  # Color accepts the following: *Gosu::Color*, *Array* (with 2 colors), or a *Hash* with keys: _from:_ and _to:_ both colors.
  #
  # With a *Gosu::Color* the arc will be painted with color
  #
  # With an *Array* the first *Gosu::Color* with be the innermost color and the last *Gosu::Color* with be the outermost color
  #
  # With a *Hash* the arc will smoothly transition from the start of the arc to the end
  # @example
  #   # Using a Hash
  #   Gosu.draw_arc(100, 100, 50, 0.5, 128, 4, {from: Gosu::Color::BLUE, to: Gosu::Color::GREEN}, 0, :default)
  #
  #   # Using an Array
  #   Gosu.draw_arc(100, 100, 50, 0.5, 128, 4, [Gosu::Color::BLUE, Gosu::Color::GREEN], 0, :default)
  #
  #   # Using a Gosu::Color
  #   Gosu.draw_arc(100, 100, 50, 0.5, 128, 4, Gosu::Color::BLUE, 0, :default)
  #
  #
  # @param x X position.
  # @param y Y position.
  # @param radius radius of arc, in pixels.
  # @param percentage how complete the segment is, _0.0_ is 0% and _1.0_ is 100%.
  # @param segments how many segments for arc, more will appear smoother, less will appear jagged.
  # @param thickness how thick arc will be.
  # @param color [Gosu::Color, Array<Gosu::Color, Gosu::Color>, Hash{from: start_color, to: end_color}] color or colors to draw the arc with.
  # @param z Z position.
  # @param mode blend mode.
  #
  # @note _thickness_ is subtracted from radius, meaning that the arc will grow towards the origin, not away from it.
  #
  # @return [void]
  def self.draw_arc(x, y, radius, percentage = 1.0, segments = 128, thickness = 4, color = Gosu::Color::WHITE, z = 0, mode = :default)
    segments = 360.0 / segments

    return if percentage == 0.0

    0.step((359 * percentage), percentage > 0 ? segments : -segments) do |angle|
      angle2 = angle + segments

      point_a_left_x = x + Gosu.offset_x(angle, radius - thickness)
      point_a_left_y = y + Gosu.offset_y(angle, radius - thickness)

      point_a_right_x = x + Gosu.offset_x(angle2, radius - thickness)
      point_a_right_y = y + Gosu.offset_y(angle2, radius - thickness)

      point_b_left_x = x + Gosu.offset_x(angle, radius)
      point_b_left_y = y + Gosu.offset_y(angle, radius)

      point_b_right_x = x + Gosu.offset_x(angle2, radius)
      point_b_right_y = y + Gosu.offset_y(angle2, radius)

      if color.is_a?(Array)
        Gosu.draw_quad(
          point_a_left_x, point_a_left_y, color.first,
          point_b_left_x, point_b_left_y, color.last,
          point_a_right_x, point_a_right_y, color.first,
          point_b_right_x, point_b_right_y, color.last,
          z, mode
        )
      elsif color.is_a?(Hash)
        start_color = color[:from]
        end_color = color[:to]

        color_a = Gosu::Color.rgba(
          (end_color.red - start_color.red) * (angle / 360.0) + start_color.red,
          (end_color.green - start_color.green) * (angle / 360.0) + start_color.green,
          (end_color.blue - start_color.blue) * (angle / 360.0) + start_color.blue,
          (end_color.alpha - start_color.alpha) * (angle / 360.0) + start_color.alpha,
        )
        color_b = Gosu::Color.rgba(
          (end_color.red - start_color.red) * (angle2 / 360.0) + start_color.red,
          (end_color.green - start_color.green) * (angle2 / 360.0) + start_color.green,
          (end_color.blue - start_color.blue) * (angle2 / 360.0) + start_color.blue,
          (end_color.alpha - start_color.alpha) * (angle2 / 360.0) + start_color.alpha,
        )

        Gosu.draw_quad(
          point_a_left_x, point_a_left_y, color_a,
          point_b_left_x, point_b_left_y, color_a,
          point_a_right_x, point_a_right_y, color_b,
          point_b_right_x, point_b_right_y, color_b,
          z, mode
        )
      else
        Gosu.draw_quad(
          point_a_left_x, point_a_left_y, color,
          point_b_left_x, point_b_left_y, color,
          point_a_right_x, point_a_right_y, color,
          point_b_right_x, point_b_right_y, color,
          z, mode
        )
      end
    end
  end
end