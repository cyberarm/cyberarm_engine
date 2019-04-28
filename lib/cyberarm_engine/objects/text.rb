module CyberarmEngine
  class Text
    CACHE = {}

    attr_accessor :x, :y, :z, :size, :factor_x, :factor_y, :color, :shadow, :shadow_size, :options
    attr_reader :text, :textobject

    def initialize(text, options={})
      @text = text || ""
      @options = options
      @size = options[:size] || 18
      @font = options[:font] || "sans-serif"#Gosu.default_font_name
      @x = options[:x] || 0
      @y = options[:y] || 0
      @z = options[:z] || 1025
      @factor_x = options[:factor_x]  || 1
      @factor_y = options[:factor_y]  || 1
      @color    = options[:color]     || Gosu::Color::WHITE
      @alignment= options[:alignment] || nil
      @shadow   = true  if options[:shadow] == true
      @shadow   = false if options[:shadow] == false
      @shadow   = true if options[:shadow] == nil
      @shadow_size = options[:shadow_size] ? options[:shadow_size] : 1
      @shadow_alpha= options[:shadow_alpha] ? options[:shadow_alpha] : 30
      @textobject = check_cache(@size, @font)

      if @alignment
        case @alignment
        when :left
          @x = 0+BUTTON_PADDING
        when :center
          @x = ($window.width/2)-(@textobject.text_width(@text)/2)
        when :right
          @x = $window.width-BUTTON_PADDING-@textobject.text_width(@text)
        end
      end

      return self
    end

    def check_cache(size, font_name)
      available = false
      font      = nil

      if CACHE[size]
        if CACHE[size][font_name]
          font = CACHE[size][font_name]
          available = true
        else
          available = false
        end
      else
        available = false
      end

      unless available
        font = Gosu::Font.new(@size, name: @font)
        CACHE[@size] = {} unless CACHE[@size].is_a?(Hash)
        CACHE[@size][@font] = font
      end

      return font
    end

    def text=(string)
      @rendered_shadow = nil
      @text = string
    end

    def width
      textobject.text_width(@text)
    end

    def height
      (@text.lines.count) * textobject.height
    end

    def draw
      if @shadow && !ARGV.join.include?("--no-shadow")
        @shadow_alpha = 30 if @color.alpha > 30
        @shadow_alpha = @color.alpha if @color.alpha <= 30
        shadow_color = Gosu::Color.rgba(@color.red, @color.green, @color.blue, @shadow_alpha)

        _x = @shadow_size
        _y = @shadow_size

        @rendered_shadow ||= Gosu.render((self.width+(shadow_size*2)).ceil, (self.height+(@shadow_size*2)).ceil) do
          @textobject.draw_markup(@text, _x-@shadow_size, _y, @z)
          @textobject.draw_markup(@text, _x-@shadow_size, _y-@shadow_size, @z)

          @textobject.draw_markup(@text, _x, _y-@shadow_size, @z, @factor_x)
          @textobject.draw_markup(@text, _x+@shadow_size, _y-@shadow_size, @z)

          @textobject.draw_markup(@text, _x, _y+@shadow_size, @z)
          @textobject.draw_markup(@text, _x-@shadow_size, _y+@shadow_size, @z)

          @textobject.draw_markup(@text, _x+@shadow_size, _y, @z)
          @textobject.draw_markup(@text, _x+@shadow_size, _y+@shadow_size, @z)
        end
        @rendered_shadow.draw(@x-@shadow_size, @y-@shadow_size, @z, @factor_x, @factor_y, shadow_color)
      end

      @textobject.draw_markup(@text, @x, @y, @z, @factor_x, @factor_y, @color)
    end

    def alpha=(n)
      @color = Gosu::Color.rgba(@color.red, @color.green, @color.blue, n)
    end

    def alpha
      @color.alpha
    end

    def update; end
  end
end
