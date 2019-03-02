module CyberarmEngine
  class Flow < Container
    include Common

    def layout
      @children.each do |child|
        child.recalculate

        if fits_on_line?(child)
          position_on_current_line(child)
        else
          @current_position.x = @margin_left + @x

          move_to_next_line(child)
        end
      end
    end
  end
end