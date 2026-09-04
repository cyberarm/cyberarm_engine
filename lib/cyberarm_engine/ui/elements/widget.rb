module CyberarmEngine
  class Element
    # Special container that has a layout like a Flow
    # and makes all its children mirror its styling (i.e. hover, active, disabled...)
    class Widget < Flow
      def update_styles(style = :default)
        super

        @children.each do |child|
          recursive_styles(style, self)
        end
      end

      # Make child elements mirror the widgets styling
      # disabled elements will not have their styling overridden
      def recursive_styles(style, container)
        container.children.each do |child|
          child.update_styles(style)

          recursive_styles(style, child) if child.is_a?(Container)
        end
      end

      # Enable child elements to display their tooltips
      # but fall back to the Widget if no hit element has a tip
      def tip
        parent_scroll_position = CyberarmEngine::Vector.new

        element = self
        while (parent_element = element.parent)
          parent_scroll_position += parent_element.scroll_position

          element = parent_element
        end

        elements = hit_element?(window.mouse_x - parent_scroll_position.x, window.mouse_y - parent_scroll_position.y)

        return @tip unless elements

        elements.delete(self) # prevent infinite recursive loop (Widget#tip)
        elements.reverse.find { |e| !e.tip.empty? }&.tip || @tip
      end
    end
  end
end
