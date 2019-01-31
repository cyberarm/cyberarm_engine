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
      background: Gosu::Color.rgb(12,12,12),

      padding: 20,
      margin:   0,

      interactive_stroke:            Gosu::Color::WHITE,
      interactive_active_stroke:     Gosu::Color::BLACK,

      interactive_background:        Gosu::Color::GRAY,
      interactive_hover_background:  Gosu::Color.rgb(100, 100, 100),
      interactive_active_background: Gosu::Color.rgb(50, 50, 50),

      text_size: 22,
      text_shadow: true,
      font: "Consolas"
    }

    attr_accessor :x, :y, :z
    attr_accessor :offset_x, :offset_y

    def initialize(options = {}, block = nil)
      options = (THEME).merge(DEFAULTS).merge(options)
      @options = options
      @block = block

      @offset_x = 0
      @offset_y = 0

      @x = options[:x]
      @y = options[:y]
      @z = options[:z]

      @width = options[:width]
      @height = options[:width]

      @padding = options[:padding]
      @margin  = options[:margin]

      @parent = options[:parent]
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
      if $window.mouse_x.between?(@x + @offset_x, @x + @offset_x + width)
        if $window.mouse_y.between?(@y + @offset_y, @y + @offset_y + height)
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

    def recalculate
    end

    def value
      raise "#{self.klass}#value was not overridden!"
    end
  end
end