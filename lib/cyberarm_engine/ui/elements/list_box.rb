module CyberarmEngine
  class Element
    class ListBox < Button
      attr_accessor :items
      attr_reader :choose

      def initialize(options = {}, block = nil)
        @items = options[:items] || []
        @choose = options[:choose] || @items.first

        super(@choose, options, block)

        @style.background_canvas.background = default(:background)

        @menu = Menu.new(parent: self, theme: @options[:theme])

        self.choose = @choose
      end

      def render
        super

        w = @text.textobject.text_width("▼")
        @text.textobject.draw_text("▼", @x + content_width - w, @y + @style.padding_top, @z, 1, 1, @text.color)
      end

      def choose=(item)
        valid = @items.detect { |i| i == item }

        unless valid
          warn "Invalid value '#{item}' for choose, valid options were: #{@items.map { |i| "#{i.inspect}" }.join(", ")}"
          item = @items.first

          raise "No items list" unless item
        end

        @choose = item

        self.value = item.to_s

        recalculate
      end

      def released_left_mouse_button(_sender, _x, _y)
        show_menu

        :handled
      end

      def clicked_left_mouse_button(_sender, _x, _y)
        # @block&.call(self.value) if @enabled

        :handled
      end

      def show_menu
        @menu.clear do

          @menu.style.width = width

          @items.each do |item|
            # prevent already selected item from appearing in list
            # NOTE: Remove this? Might be kinda confusing...
            next if item == self.value

            root.gui_state.menu_item(item, width: 1.0, margin: 0, border_color: 0x00ffffff) do
              self.choose = item
              @block&.call(self.value)
            end
          end
        end

        recalculate

        @menu.show
      end
    end
  end
end
