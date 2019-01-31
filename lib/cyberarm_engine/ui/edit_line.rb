module CyberarmEngine
  class EditLine < Element
    WIDTH = 200
    FOCUS_BACKGROUND_COLOR = Gosu::Color.rgb(150,150,144)
    NO_FOCUS_BACKGROUND_COLOR = Gosu::Color.rgb(130,130,130)

    attr_accessor :text, :x, :y, :width, :size, :color, :type, :focus
    attr_reader :text_object, :text_input, :height

    def initialize(text, options = {})
      @text = text
      @x, @y= x, y
      @width= width
      @size = size
      @color= color
      @tooltip=tooltip
      @type = type

      @focus = false

      @text_object = Text.new(text, x: x, y: y, size: size, color: color, shadow: true)
      @height      = @text_object.height
      @text_input  = Gosu::TextInput.new
      @text_input.text = @text

      @background_color = NO_FOCUS_BACKGROUND_COLOR

      @carot_ticks = 0
      @carot_width = 2.5
      @carot_height= @text_object.height
      @carot_color = Gosu::Color.rgb(50,50,25)
      @carot_show_ticks = 25
      @show_carot  = true

      return self
    end

    def text=(string)
      @text = string
      @text_input.text, @text_object.text = @text, @text
    end

    def draw
      $window.draw_rect(x, y, width, height, Gosu::Color::BLACK)
      $window.draw_rect(x+1, y+1, width-2, height-2, @background_color)
      Gosu.clip_to(x, @text_object.y, width, @text_object.height) do
        @text_object.draw

        # Carot (Cursor)
        $window.draw_rect((@x+@text_object.width)-@x_offset, @text_object.y, @carot_width, @carot_height, @carot_color) if @show_carot && @focus
      end

    end

    def update
      @text_object.y = @y+BUTTON_PADDING

      if (@text_object.width+@carot_width)-@width >= 0
        @x_offset = (@text_object.width+@carot_width)-@width
      else
        @x_offset = 0
      end

      @text     = @text_object.text
      @carot_ticks+=1
      if @carot_ticks >= @carot_show_ticks
        if @show_carot
          @show_carot = false
        else
          @show_carot = true
        end

        @carot_ticks = 0
      end

      if @focus
        @text_object.text = @text_input.text
        $window.text_input = @text_input unless $window.text_input == @text_input
      end

      if mouse_over? && $window.button_down?(Gosu::MsLeft)
        @focus = true
        @background_color = FOCUS_BACKGROUND_COLOR
      end
      if !mouse_over? && $window.button_down?(Gosu::MsLeft)
        @focus = false
        $window.text_input = nil
        @background_color = NO_FOCUS_BACKGROUND_COLOR
      end

      if @text_object.width >= @width
        @text_object.x = self.fixed_x-@x_offset
      else
        @text_object.x = self.fixed_x
      end
    end

    def width(text_object = @text_object)
      # text_object.textobject.text_width(text_object.text)+BUTTON_PADDING*2
      @width
    end

    def height(text_object = @text_object)
      text_object.textobject.height+BUTTON_PADDING*2
    end
  end
end