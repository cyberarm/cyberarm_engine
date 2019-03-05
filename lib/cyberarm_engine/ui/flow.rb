module CyberarmEngine
  class Flow < Container
    include Common

    def layout
      @children.each do |child|
        if fits_on_line?(child)
          position_on_current_line(child)
        else
          @current_position.x = @margin_left + @x
          @current_position.y += child.height + child.margin_bottom

          child.x = element.margin_left + @current_position.x
          child.y = element.margin_top  + @current_position.y

          child.recalculate

          @current_position.x += child.width + child.margin_right
        end
      end
    end
  end
end