module CyberarmEngine
  class Element
    class CheckBox < Flow
      def initialize(text, options, block = nil)
        super({}, block = nil)
        options[:toggled] = options[:checked]

        @toggle_button = ToggleButton.new(options)
        @label         = Label.new(text, options)

        @label.subscribe(:holding_left_mouse_button) do |sender, x, y|
          @toggle_button.left_mouse_button(sender, x, y)
        end

        @label.subscribe(:released_left_mouse_button) do |sender, x, y|
          @toggle_button.released_left_mouse_button(sender, x, y)
        end

        @label.subscribe(:clicked_left_mouse_button) do |sender, x, y|
          @toggle_button.clicked_left_mouse_button(sender, x, y)
        end

        @label.subscribe(:enter) do |sender|
          @toggle_button.enter(sender)
        end

        @label.subscribe(:leave) do |sender|
          @toggle_button.leave(sender)
        end

        add(@toggle_button)
        add(@label)
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
    end
  end
end