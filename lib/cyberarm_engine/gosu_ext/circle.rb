module Gosu
  # Sourced from https://gist.github.com/ippa/662583
  def self.draw_circle(cx,cy,r, z = 9999,color = Gosu::Color::GREEN, step = 10)
    0.step(360, step) do |a1|
      a2 = a1 + step
      draw_line(cx + Gosu.offset_x(a1, r), cy + Gosu.offset_y(a1, r), color, cx + Gosu.offset_x(a2, r), cy + Gosu.offset_y(a2, r), color, z)
    end
  end
end