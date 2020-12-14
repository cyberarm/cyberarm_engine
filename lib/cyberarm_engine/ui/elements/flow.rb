module CyberarmEngine
  class Element
    class Flow < Container
      def layout
        @children.each do |child|
          if fits_on_line?(child)
            position_on_current_line(child)
          else
            position_on_next_line(child)
          end
        end
      end
    end
  end
end
