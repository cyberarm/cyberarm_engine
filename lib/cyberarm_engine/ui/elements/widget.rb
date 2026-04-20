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
        elements = hit_element?(window.mouse_x, window.mouse_y)

        return @tip unless elements

        elements.delete(self) # prevent infinite recursive loop (Widget#tip)
        elements.reverse.find { |e| !e.tip.empty? }&.tip || @tip
      end
    end
  end
end
