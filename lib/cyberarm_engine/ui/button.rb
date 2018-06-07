module CyberarmEngine
  BUTTON_TEXT_COLOR        = Gosu::Color::WHITE
  BUTTON_TEXT_ACTIVE_COLOR = Gosu::Color::BLACK
  BUTTON_COLOR             = Gosu::Color.rgb(12,12,12)
  BUTTON_HOVER_COLOR       = Gosu::Color.rgb(100, 100, 100)
  BUTTON_ACTIVE_COLOR      = Gosu::Color.rgb(50, 50, 50)
  BUTTON_TEXT_SIZE         = 20
  BUTTON_PADDING           = 10

  class Button
    attr_accessor :text, :x, :y, :offset_x, :offset_y, :tooltip, :block

    def initialize(text, x, y, auto_manage = true, tooltip = "", &block)
      @text = Text.new(text, x: x, y: y, size: BUTTON_TEXT_SIZE, color: BUTTON_TEXT_COLOR, shadow: true)
      @tooltip=Text.new(tooltip, x: x, y: y-(height/4*3), z: 10_000, size: BUTTON_TEXT_SIZE, color: BUTTON_TEXT_COLOR, shadow: false)
      @x = x
      @y = y
      _x_ = @x+(@text.textobject.text_width(@text.text)/2)-(@tooltip.textobject.text_width(@tooltip.text)/2)
      @tooltip.x = _x_+BUTTON_PADDING
      auto_adjust_tooltip_position
      @offset_x, @offset_y = 0, 0
      if block
        @block = Proc.new{yield(self)}
      else
        @block = Proc.new {}
      end

      Window.instance.elements.push(self) if auto_manage

      return self
    end

    def update_position_toolip
      _x_ = @x+(@text.textobject.text_width(@text.text)/2)-(@tooltip.textobject.text_width(@tooltip.text)/2)
      @tooltip.x = _x_+BUTTON_PADDING
      auto_adjust_tooltip_position
    end

    def auto_adjust_tooltip_position
      if @tooltip.x <= 1
        @tooltip.x = 2
      elsif @tooltip.x+@tooltip.textobject.text_width(@tooltip.text) > $window.width-(BUTTON_PADDING+1)
        @tooltip.x = $window.width-@tooltip.textobject.text_width(@tooltip.text)
      end
    end

    def draw
      @text.draw

      $window.draw_rect(@x, @y, width, height, BUTTON_COLOR)

      if mouse_clicked_on_check
        $window.draw_rect(@x+1, @y+1, width-2, height-2, BUTTON_ACTIVE_COLOR)
      elsif mouse_over?
        $window.draw_rect(@x+1, @y+1, width-2, height-2, BUTTON_HOVER_COLOR)
        show_tooltip
      else
        $window.draw_rect(@x+1, @y+1, width-2, height-2, BUTTON_COLOR)
      end

    end

    def update
      @text.x = @x+BUTTON_PADDING
      @text.y = @y+BUTTON_PADDING
    end

    def button_up(id)
      case id
      when Gosu::MsLeft
        click_check
      end
    end

    def click_check
      if mouse_over?
        puts "Clicked: #{@text.text}"
        @block.call if @block.is_a?(Proc)
      end
    end

    def mouse_clicked_on_check
      if mouse_over? && Gosu.button_down?(Gosu::MsLeft)
        true
      end
    end

    def mouse_over?
      if $window.mouse_x.between?(@x+@offset_x, @x+@offset_x+width)
        if $window.mouse_y.between?(@y+@offset_y, @y+@offset_y+height)
          true
        end
      end
    end

    def show_tooltip
      if @tooltip.text != ""
        x = @tooltip.x-BUTTON_PADDING

        $window.draw_rect(x, @y-height, width(@tooltip), height(@tooltip), BUTTON_ACTIVE_COLOR, 9_999)
        $window.draw_rect(x-1, @y-height-1, width(@tooltip)+2, height(@tooltip)+2, Gosu::Color::WHITE, 9_998)
        @tooltip.draw
      end
    end

    def width(text_object = @text)
      text_object.textobject.text_width(text_object.text)+BUTTON_PADDING*2
    end

    def height(text_object = @text)
      text_object.textobject.height+BUTTON_PADDING*2
    end

    def set_offset(x, y)
      @offset_x, @offset_y = x, y
    end

    def update_text(string)
      @text.text = string
    end
  end
end