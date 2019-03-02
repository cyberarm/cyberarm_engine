module CyberarmEngine
  class Stack < Container
    include Common

    def layout
      @children.each do |child|
        move_to_next_line(child)
      end
    end
  end
end