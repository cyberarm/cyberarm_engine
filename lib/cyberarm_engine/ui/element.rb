module CyberarmEngine
  class Element
    DEFAULTS = {
      x: 0,
      y: 0,
      z: 30,

      width: 0,
      height: 0
    }

    THEME = {
      stroke:     Gosu::Color::WHITE,
      fill:       Gosu::Color::NONE,
      background: Gosu::Color::NONE,
      checkmark: "√", # √

      padding: 20,
      margin:   2,

      element_background: Gosu::Color.rgb(12,12,12),

      interactive_stroke:            Gosu::Color::WHITE,
      interactive_active_stroke:     Gosu::Color::GRAY,

      interactive_background:        Gosu::Color::GRAY,
      interactive_hover_background:  Gosu::Color.rgb(100, 100, 100),
      interactive_active_background: Gosu::Color.rgb(50, 50, 50),
      interactive_border_size: 1,

      edit_line_width: 200,
      edit_line_password_character: "•", # •
      caret_width: 2,
      caret_color: Gosu::Color.rgb(50,50,25),
      caret_interval: 500,

      image_retro: false,

      text_size: 22,
      text_shadow: true,
      font: "Consolas"
    }

    attr_accessor :x, :y, :z, :width, :height, :padding, :margin, :focus

    def initialize(options = {}, block = nil)
      @parent = options[:parent] # parent Container (i.e. flow/stack)
      options = (THEME).merge(DEFAULTS).merge(@parent.theme).merge(options)
      @options = options
      @block = block

      @x = options[:x]
      @y = options[:y]
      @z = options[:z]

      @width = options[:width]
      @height = options[:width]

      @padding = options[:padding]
      @margin  = options[:margin]

      @focus = false
    end

    def draw
    end

    def update
    end

    def button_down(id)
    end

    def button_up(id)
    end

    def mouse_over?
      if $window.mouse_x.between?(relative_x, relative_x + width)
        if $window.mouse_y.between?(relative_y, relative_y + height)
          true
        end
      end
    end

    def width
      @width + (@padding * 2)
    end

    def height
      @height + (@padding * 2)
    end

    def relative_x
      @parent.x + @parent.scroll_x + @x + @margin
    end

    def relative_y
      @parent.y + @parent.scroll_y + @y + @margin
    end

    def recalculate
      raise "#{self.class}#recalculate was not overridden!"
    end

    def value
      raise "#{self.class}#value was not overridden!"
    end
  end
end