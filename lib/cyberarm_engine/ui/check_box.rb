module CyberarmEngine
  class CheckBox
    SIZE = 22

    attr_accessor :x, :y, :checked
    attr_reader :text

    def initialize(x, y, checked = false, size = CheckBox::SIZE)
      @x, @y = x, y
      @checked = checked
      @size = size
      @text = Text.new("✔", false, x: x, y: y, size: size, color: BUTTON_TEXT_COLOR, shadow: true)
      return self
    end

    def x=(int)
      @x = int
      @text.x = int
    end

    def y=(int)
      @y = int
      @text.y = int
    end

    def draw
      $window.draw_rect(@x, @y, width, height, Gosu::Color::BLACK)
      if mouse_over?
        $window.draw_rect(@x+1, @y+1, width-2, height-2, BUTTON_HOVER_COLOR)
      else
        if @checked
          $window.draw_rect(@x+1, @y+1, width-2, height-2, BUTTON_ACTIVE_COLOR)
        else
          $window.draw_rect(@x+1, @y+1, width-2, height-2, BUTTON_COLOR)
        end
      end
      if @checked
        @text.draw
      end
    end

    def update
      @text.x = @x+BUTTON_PADDING
      @text.y = @y+BUTTON_PADDING
    end

    def button_up(id)
      if mouse_over? && id == Gosu::MsLeft
        if @checked
          @checked = false
        else
          @checked = true
        end
      end
    end

    def mouse_over?
      if $window.mouse.x.between?(@x, @x+width)
        if $window.mouse.y.between?(@y, @y+height)
          true
        end
      end
    end

    def width(text_object = @text)
      text_object.textobject.text_width(text_object.text)+BUTTON_PADDING*2
    end

    def height(text_object = @text)
      text_object.textobject.height+BUTTON_PADDING*2
    end
  end
end