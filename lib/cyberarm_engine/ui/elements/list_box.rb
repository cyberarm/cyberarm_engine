module CyberarmEngine
  class Element
    class ListBox < Button
      attr_accessor :items
      attr_reader :choose

      def initialize(options = {}, block = nil)
        @items = options[:items] ? options[:items] : []
        @choose = options[:choose] ? options[:choose] : @items.first

        super(@choose, options, block)

        @style.background_canvas.background = default(:background)

        # TODO: "Clean Up" into own class?
        @menu = Stack.new(parent: parent, width: @options[:width], theme: @options[:theme])
        @menu.define_singleton_method(:recalculate_menu) do
          @x = @__list_box.x
          @y = @__list_box.y + @__list_box.height
        end
        @menu.instance_variable_set(:"@__list_box", self)

        def @menu.recalculate
          super
          recalculate_menu
        end
      end

      def choose=(item)
        valid = @items.detect { |i| i == item }
        return unless valid # TODO: Throw an error?
        @choose = item

        self.value = item.to_s

        recalculate
      end

      def released_left_mouse_button(sender, x, y)
        show_menu

        return :handled
      end

      def show_menu
        @menu.clear
        @items.each do |item|
          [ @block]
          block = proc { self.choose = item; @block.call(item) if @block }
          b = Button.new(item, { parent: @menu, width: 1.0, theme: @options[:theme], margin: 0, border_color: 0x00ffffff }, block)

          @menu.add(b)
        end
        recalculate

        root.gui_state.show_menu(@menu)
      end

      def recalculate
        super

        @menu.recalculate
      end
    end
  end
end