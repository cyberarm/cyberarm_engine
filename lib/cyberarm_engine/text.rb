module CyberarmEngine
  class Text
    CACHE = {}

    attr_accessor :x, :y, :z, :size, :options
    attr_reader :text, :textobject, :factor_x, :factor_y, :color,
                :border, :border_size, :border_alpha, :border_color,
                :shadow, :shadow_size, :shadow_alpha, :shadow_color

    def initialize(text, options = {})
      @text = text.to_s || ""
      @options = options
      @size = options[:size] || 18
      @font = options[:font] || Gosu.default_font_name
      @x = options[:x] || 0
      @y = options[:y] || 0
      @z = options[:z] || 1025
      @factor_x = options[:factor_x]  || 1
      @factor_y = options[:factor_y]  || 1
      if options[:color]
        @color = options[:color].is_a?(Gosu::Color) ? options[:color] : Gosu::Color.new(options[:color])
      else
        @color = Gosu::Color::WHITE
      end
      @mode      = options[:mode]      || :default
      @alignment = options[:alignment] || nil

      @border   = options[:border]
      @border   = true if options[:border].nil?
      @border_size = options[:border_size] || 1
      @border_alpha = options[:border_alpha] || 30
      @border_color = options[:border_color] || Gosu::Color::BLACK

      @shadow = options[:shadow]
      @shadow_size = options[:shadow_size] || 2
      @shadow_alpha = options[:shadow_alpha] || 30
      @shadow_color = options[:shadow_color] || Gosu::Color::BLACK

      @static = options[:static] || (options[:static].nil? || options[:static] == false ? false : true)

      @textobject = check_cache(@size, @font)

      if @alignment
        case @alignment
        when :left
          @x = 0 + BUTTON_PADDING
        when :center
          @x = (CyberarmEngine::Window.instance.width / 2) - (@textobject.text_width(@text) / 2)
        when :right
          @x = CyberarmEngine::Window.instance.width - BUTTON_PADDING - @textobject.text_width(@text)
        end
      end
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

      font
    end

    def swap_font(size, font_name = @font)
      if @size != size || @font != font_name
        @size = size
        @font = font_name

        @textobject = check_cache(size, font_name)
      end
    end

    def text=(string)
      invalidate_cache! if @text != string
      @text = string
    end

    def factor_x=(n)
      invalidate_cache! if @factor_x != n
      @factor_x = n
    end

    def factor_y=(n)
      invalidate_cache! if @factor_y != n
      @factor_y = n
    end

    def color=(color)
      old_color = @color

      if color
        @color = color.is_a?(Gosu::Color) ? color : Gosu::Color.new(color)
      else
        raise "color cannot be nil"
      end

      invalidate_cache! if old_color != color
    end

    def border=(boolean)
      invalidate_cache! if @border != boolean
      @border = boolean
    end

    def border_size=(n)
      invalidate_cache! if @border_size != n
      @border_size = n
    end

    def border_alpha=(n)
      invalidate_cache! if @border_alpha != n
      @border_alpha = n
    end

    def border_color=(n)
      invalidate_cache! if @border_color != n
      @border_color = n
    end

    def width(text = @text)
      markup_width(text)
    end

    def text_width(text = @text)
      spacing = 0
      spacing += @border_size if @border
      spacing += @shadow_size if @shadow

      if text == @text && @static && @gosu_cached_text_image
        @gosu_cached_text_image&.width + spacing
      else
        textobject.text_width(text) + spacing
      end
    end

    def markup_width(text = @text)
      spacing = 0
      spacing += @border_size if @border
      spacing += @shadow_size if @shadow

      if text == @text && @static && @gosu_cached_text_image
        @gosu_cached_text_image&.width + spacing
      else
        textobject.markup_width(text) + spacing
      end
    end

    def height(text = @text)
      if text.lines.count > 0
        text.lines.count * textobject.height + @border_size + @shadow_size
      else
        @textobject.height + @border_size + @shadow_size
      end
    end

    def draw(method = :draw_markup)
      if @static
        if @border && !@cached_text_border_image
          _x = @border_size
          _y = @border_size
          _width = method == :draw_markup ? text_width : markup_width
          img = Gosu::Image.send(:"from_#{method.to_s.split("_").last}", @text, @size, font: @font)

          @cached_text_border_image = Gosu.render((_width + (@border_size * 2)).ceil, (height + (@border_size * 2)).ceil) do
            img.draw(-_x, 0, @z, @factor_x, @factor_y, @border_color, @mode)
            img.draw(-_x, -_y, @z, @factor_x, @factor_y, @border_color, @mode)

            img.draw(0, -_y, @z, @factor_x, @factor_y, @border_color, @mode)
            img.draw(_x, -_y, @z, @factor_x, @factor_y, @border_color, @mode)

            img.draw(_x, 0, @z, @factor_x, @factor_y, @border_color, @mode)
            img.draw(_x, _y, @z, @factor_x, @factor_y, @border_color, @mode)

            img.draw(0, _y, @z, @factor_x, @factor_y, @border_color, @mode)
            img.draw(-_x, _y, @z, @factor_x, @factor_y, @border_color, @mode)
          end
        end

        @cached_text_shadow_image ||= Gosu::Image.send(:"from_#{method.to_s.split("_").last}", @text, @size, font: @font) if @shadow

        @gosu_cached_text_image ||= Gosu::Image.send(:"from_#{method.to_s.split("_").last}", @text, @size, font: @font)

        @cached_text_border_image.draw(@x, @y, @z, @factor_x, @factor_y, @border_color, @mode) if @border

        @cached_text_shadow_image.draw(@x + @shadow_size, @y + @shadow_size, @z, @factor_x, @factor_y, @shadow_color, @mode) if @shadow

        @gosu_cached_text_image.draw(@x, @y, @z, @factor_x, @factor_y, @color, @mode)
      else
        if @border && !ARGV.join.include?("--no-border")
          border_alpha = @color.alpha <= 30 ? @color.alpha : @border_alpha
          border_color = @border_color || Gosu::Color.rgba(@color.red, @color.green, @color.blue,
                                                          border_alpha)
          white = Gosu::Color::WHITE

          _x = @border_size
          _y = @border_size
          _width = method == :draw_markup ? text_width : markup_width

          @cached_text_border_image ||= Gosu.render((_width + (border_size * 2)).ceil, (height + (@border_size * 2)).ceil) do
            @textobject.send(method, @text, _x - @border_size, _y, @z, @factor_x, @factor_y, white, @mode)
            @textobject.send(method, @text, _x - @border_size, _y - @border_size, @z, @factor_x, @factor_y, white, @mode)

            @textobject.send(method, @text, _x, _y - @border_size, @z, @factor_x, @factor_y, white, @mode)
            @textobject.send(method, @text, _x + @border_size, _y - @border_size, @z, @factor_x, @factor_y, white, @mode)

            @textobject.send(method, @text, _x, _y + @border_size, @z, @factor_x, @factor_y, white, @mode)
            @textobject.send(method, @text, _x - @border_size, _y + @border_size, @z, @factor_x, @factor_y, white, @mode)

            @textobject.send(method, @text, _x + @border_size, _y, @z, @factor_x, @factor_y, white, @mode)
            @textobject.send(method, @text, _x + @border_size, _y + @border_size, @z, @factor_x, @factor_y, white, @mode)
          end

          @cached_text_border_image.draw(@x - @border_size, @y - @border_size, @z, @factor_x, @factor_y, border_color)
        end

        if @shadow
          shadow_color = @shadow_color || Gosu::Color.rgba(@color.red, @color.green, @color.blue, @shadow_alpha)
          @textobject.send(method, @text, @x + @shadow_size, @y + @shadow_size, @z, @factor_x, @factor_y, shadow_color, @mode)
        end

        @textobject.send(method, @text, @x, @y, @z, @factor_x, @factor_y, @color, @mode)
      end
    end

    def alpha=(n)
      @color = Gosu::Color.rgba(@color.red, @color.green, @color.blue, n)
    end

    def alpha
      @color.alpha
    end

    def update
    end

    def invalidate_cache!
      @cached_text_border_image = nil
      @cached_text_shadow_image = nil
      @gosu_cached_text_image = nil
    end
  end
end
