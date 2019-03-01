module CyberarmEngine
  class CheckBox < Flow
    def initialize(text, options, block = nil)
      super(options = {}, block = nil)

      @toggle_button = ToggleButton.new(options)
      @label         = Label.new(text, options)

      add(@toggle_button)
      add(@label)

      @width  = @toggle_button.width + @label.width
      @height = @toggle_button.height + @label.height

      @background_color = Gosu::Color::RED

      recalculate
    end

    def text=(text)
      @label.text = text
      recalculate
    end

    def hover(sender)
      # puts "a-#{Gosu.milliseconds}"
    end

    def clicked_left_mouse_button(sender, x, y)
      @toggle_button.toggled = !@toggle_button.toggled
    end
  end
end