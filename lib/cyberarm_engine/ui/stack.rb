module CyberarmEngine
  class Stack < Container
    include Common

    def layout
      @children.each do |child|
        move_to_next_line(child)

        child.recalculate
      end

      @width  = @max_width  ? @max_width  : (@children.map {|c| c.x + c.width }.max || 0)
      @height = @max_height ? @max_height : (@children.map {|c| c.y + c.height}.max || 0)
    end
  end
end