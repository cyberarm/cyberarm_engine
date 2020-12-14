module CyberarmEngine
  class BorderCanvas
    attr_reader :element, :top, :right, :bottom, :left

    def initialize(element:)
      @element = element

      @top    = Background.new
      @right  = Background.new
      @bottom = Background.new
      @left   = Background.new
    end

    def color=(color)
      if color.is_a?(Numeric)
        @top.background    = color
        @right.background  = color
        @bottom.background = color
        @left.background   = color

      elsif color.is_a?(Gosu::Color)
        @top.background    = color
        @right.background  = color
        @bottom.background = color
        @left.background   = color

      elsif color.is_a?(Array)
        if color.size == 1
          color = color.first

        elsif color.size == 2
          @top.background    = color.first
          @right.background  = color.first
          @bottom.background = color.last
          @left.background   = color.last

        elsif color.size == 4
          @top.background    = color[0]
          @right.background  = color[1]
          @bottom.background = color[2]
          @left.background   = color[3]
        else
          raise ArgumentError, "color array was empty or had wrong number of elements (expected 2 or 4 elements)"
        end

      elsif color.is_a?(Hash)
        @top.background    = color[:top]
        @right.background  = color[:right]
        @bottom.background = color[:bottom]
        @left.background   = color[:left]
      else
        raise ArgumentError, "color '#{color}' of type '#{color.class}' was not able to be processed"
      end
    end

    def draw
      @top.draw
      @right.draw
      @bottom.draw
      @left.draw
    end

    def update
      # TOP
      @top.x = @element.x # + @element.border_thickness_left
      @top.y = @element.y
      @top.z = @element.z

      @top.width  = @element.width
      @top.height = @element.style.border_thickness_top

      # RIGHT
      @right.x = @element.x + @element.width
      @right.y = @element.y + @element.style.border_thickness_top
      @right.z = @element.z

      @right.width  = -@element.style.border_thickness_right
      @right.height = @element.height - @element.style.border_thickness_top

      # BOTTOM
      @bottom.x = @element.x
      @bottom.y = @element.y + @element.height
      @bottom.z = @element.z

      @bottom.width  = @element.width - @element.style.border_thickness_right
      @bottom.height = -@element.style.border_thickness_bottom

      # LEFT
      @left.x = @element.x
      @left.y = @element.y
      @left.z = @element.z

      @left.width  = @element.style.border_thickness_left
      @left.height = @element.height - @element.style.border_thickness_bottom

      @top.update
      @right.update
      @bottom.update
      @left.update
    end
  end
end
