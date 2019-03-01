module CyberarmEngine
  class Element
    include Theme
    include Event

    attr_accessor :x, :y, :z, :width, :height, :padding, :margin, :enabled

    def initialize(options = {}, block = nil)
      @parent = options[:parent] # parent Container (i.e. flow/stack)
      options = (THEME).merge(DEFAULTS).merge(@parent.theme).merge(options)
      @options = options
      @block = block

      @x = options[:x]
      @y = options[:y]
      @z = options[:z]

      @fixed_x = @x if @x != 0
      @fixed_y = @y if @y != 0

      @width = options[:width]
      @height = options[:width]

      @max_width  = @width  if @width  != 0
      @max_height = @height if @height != 0

      @padding = options[:padding]
      @margin  = options[:margin]

      @enabled = true
    end

    def enabled?
      @enabled
    end

    def draw
    end

    def update
    end

    def button_down(id)
    end

    def button_up(id)
    end

    def hit?(x, y)
      x.between?(relative_x, relative_x + width) &&
      y.between?(relative_y, relative_y + height)
    end

    def width
      @width + (@padding * 2)
    end

    def height
      @height + (@padding * 2)
    end

    def relative_x
      @x# + @margin
    end

    def relative_y
      @y# + @margin
    end

    def recalculate
      raise "#{self.class}#recalculate was not overridden!"
    end

    def value
      raise "#{self.class}#value was not overridden!"
    end
  end
end