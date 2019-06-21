module CyberarmEngine
  class CheckBox < Flow
    def initialize(text, options, block = nil)
      super({}, block = nil)
      options[:toggled] = options[:checked]

      @toggle_button = ToggleButton.new(options)
      @label         = Label.new(text, options)

      define_label_singletons

      add(@toggle_button)
      add(@label)

      @style.width  = @toggle_button.width + @label.width
      @style.height = @toggle_button.height + @label.height
    end

    def text=(text)
      @label.text = text
      recalculate
    end

    def value
      @toggle_button.value
    end

    def value=(bool)
      @toggle_button.vlaue = bool
    end

    def define_label_singletons
      @label.define_singleton_method(:_toggle_button) do |button|
        @_toggle_button = button
      end

      @label._toggle_button(@toggle_button)

      @label.define_singleton_method(:holding_left_mouse_button) do |sender, x, y|
        @_toggle_button.left_mouse_button(sender, x, y)
      end

      @label.define_singleton_method(:released_left_mouse_button) do |sender, x, y|
        @_toggle_button.released_left_mouse_button(sender, x, y)
      end

      @label.define_singleton_method(:clicked_left_mouse_button) do |sender, x, y|
        @_toggle_button.clicked_left_mouse_button(sender, x, y)
      end

      @label.define_singleton_method(:enter) do |sender|
        @_toggle_button.enter(sender)
      end

      @label.define_singleton_method(:leave) do |sender|
        @_toggle_button.leave(sender)
      end
    end
  end
end