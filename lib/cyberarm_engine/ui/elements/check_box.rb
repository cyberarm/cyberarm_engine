module CyberarmEngine
  class Element
    class CheckBox < Flow
      def initialize(text, options, block = nil)
        super(options, block)
        options[:toggled] = options[:checked]

        options[:parent] = self
        @toggle_button = ToggleButton.new(options)

        options[:parent] = self
        @label = TextBlock.new(text, options)

        @label.subscribe(:holding_left_mouse_button) do |sender, x, y|
          @toggle_button.left_mouse_button(sender, x, y)
        end

        @label.subscribe(:released_left_mouse_button) do |sender, x, y|
          @toggle_button.released_left_mouse_button(sender, x, y)
        end

        @label.subscribe(:clicked_left_mouse_button) do |sender, x, y|
          @toggle_button.clicked_left_mouse_button(sender, x, y)
          publish(:changed, @toggle_button.value)
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
        @toggle_button.value = bool
        publish(:changed, @toggle_button.value)
      end
    end
  end
end
