module CyberarmEngine
  class Flow < Container
    include Common

    def initialize(options = {}, block = nil)
      @mode = :flow
      super
    end

    def layout
      @children.each do |child|
        if fits_on_line?(child)
          position_on_current_line(child)
        else
          move_to_next_line(child)
        end

        child.recalculate
      end

      @width  = @max_width ? @max_width : (@children.map {|c| c.x + c.width}.max || 0)
      @height = @max_height ? @max_height : (@children.map {|c| c.y + c.height}.max || 0)
    end
  end
end