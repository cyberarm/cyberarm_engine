module CyberarmEngine
  class Container
    attr_accessor :text_color
    attr_reader :elements, :x, :y, :width, :height, :options
    attr_reader :scroll_x, :scroll_y, :internal_width, :internal_height

    def initialize(x = 0, y = 100, width = $window.width, height = $window.height, options = {})
      @x, @y, @width, @height, @internal_width, @internal_height = x, y, width, height-y, width, height-y
      @scroll_x, @scroll_y = 0, 0
      @scroll_speed = 10
      puts "#{self.class}: width #{width}, height #{@height}"

      @options = {}
      @allow_recreation_on_resize = true
      @text_color = options[:text_color] || Gosu::Color::WHITE
      @elements = []

      if defined?(self.setup); setup; end
    end

    def draw
      Gosu.clip_to(x, y, width, height) do
        Gosu.translate(scroll_x, scroll_y) do
          @elements.each(&:draw)
        end
      end
    end

    def update
      @elements.each(&:update)
    end

    def button_up(id)
      if $window.mouse_x.between?(@x, @x+@width)
        if $window.mouse_y.between?(@y, @y+@height)
          case id
          when Gosu::MsWheelUp
            @scroll_y+=@scroll_speed
            @scroll_y = 0 if @scroll_y > 0
            @elements.each {|e| e.set_offset(@scroll_x, @scroll_y) if e.is_a?(Button) }
          when Gosu::MsWheelDown
            @scroll_y-=@scroll_speed
            if $window.height-@internal_height-y > 0
              @scroll_y = 0
              p "H: #{@height-@internal_height}", "Y: #{@scroll_y}"
            else
              @scroll_y = @height-@internal_height if @scroll_y <= @height-@internal_height
            end

            @elements.each {|e| e.set_offset(@scroll_x, @scroll_y) if e.is_a?(Button) }
          end
        end
      end

      @elements.each {|e| if defined?(e.button_up); e.button_up(id); end}
    end

    def build(&block)
      yield(self)
    end

    def text(text, x, y, size = 18, color = self.text_color, alignment = nil, font = nil)
      relative_x = @x+x
      relative_y = @y+y
      _text      = Text.new(text, x: relative_x, y: relative_y, size: size, color: color, alignment: alignment, font: font)
      @elements.push(_text)
      if _text.y-(_text.height*2) > @internal_height
        @internal_height+=_text.height
      end

      return _text
    end

    def button(text, x, y, tooltip = "", &block)
      relative_x = @x+x
      relative_y = @y+y
      _button    = Button.new(text, relative_x, relative_y, false, tooltip) { if block.is_a?(Proc); block.call; end }
      @elements.push(_button)
      if _button.y-(_button.height*2) > @internal_height
        @internal_height+=_button.height
      end

      return _button
    end

    def input(text, x, y, width = Input::WIDTH, size = 18, color = Gosu::Color::BLACK, tooltip = "")
      relative_x = @x+x
      relative_y = @y+y
      _input     = Input.new(text, relative_x, relative_y, width, size, color)
      @elements.push(_input)
      if _input.y-(_input.height*2) > @internal_height
        @internal_height+=_input.height
      end

      return _input
    end

    def check_box(x, y, checked = false, size = CheckBox::SIZE)
      relative_x = @x+x
      relative_y = @y+y
      _check_box = CheckBox.new(relative_x, relative_y, checked, size)
      @elements.push(_check_box)
      if _check_box.y-(_check_box.height*2) > @internal_height
        @internal_height+=_check_box.height
      end

      return _check_box
    end

    def resize
      if @allow_recreation_on_resize
        $window.active_container = self.class.new
      end
    end

    # Fills container background with color
    def fill(color = Gosu::Color::BLACK, z = 0)
      $window.draw_rect(@x, @y, @width, @height, color, z)
    end

    def set_layout_y(start, spacing)
      @layout_y_start = start
      @layout_y_spacing = spacing
      @layout_y_count = 0
    end

    def layout_y(stay = false)
      i = @layout_y_start+(@layout_y_spacing*@layout_y_count)
      @layout_y_count+=1 unless stay
      return i
    end

    # Return X position relative to container
    def relative_x(int)
      int-self.x
    end

    # Return Y position relative to container
    def relative_y(int)
      int-self.y
    end

    def calc_percentage(positive, total)
      begin
        i = ((positive.to_f/total.to_f)*100.0).round(2)
        if !i.nan?
          return "#{i}%"
        else
          "N/A"
        end
      rescue ZeroDivisionError => e
        puts e
        return "N/A" # 0 / 0, safe to assume no actionable data
      end
    end
  end
end