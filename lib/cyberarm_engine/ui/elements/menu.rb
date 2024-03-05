module CyberarmEngine
  class Element
    class Menu < Stack
      def recalculate
        super

        recalculate_menu
      end

      def recalculate_menu
        # FIXME: properly find scrollable parent, if any.
        parent_scroll_top = parent&.parent ? parent.parent.scroll_top : 0

        @x = @parent.x
        @y = parent_scroll_top + @parent.y + @parent.height

        @y = (parent_scroll_top + @parent.y) - height if @y + height > window.height
      end

      def show
        recalculate

        root.gui_state.show_menu(self)
      end
    end
  end
end
