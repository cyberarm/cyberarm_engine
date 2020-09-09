module CyberarmEngine
  class Element
    class Label < Element
      def initialize(text, options = {}, block = nil)
        super(options, block)

        @text = Text.new(
                        text, font: @options[:font], z: @z, color: @options[:color],
                        size: @options[:text_size], shadow: @options[:text_shadow],
                        shadow_size: @options[:text_shadow_size],
                        shadow_color: @options[:text_shadow_color]
                      )
      end

      def render
        @text.draw
      end

      def clicked_left_mouse_button(sender, x, y)
        @block.call(self) if @block

        # return :handled
      end

      def recalculate
        @width, @height = 0, 0

        _width = dimensional_size(@style.width, :width)
        _height= dimensional_size(@style.height,:height)

        @width = _width  ? _width  : @text.width.round
        @height= _height ? _height : @text.height.round

        @text.y = @style.border_thickness_top + @style.padding_top  + @y
        @text.z = @z + 3

        if text_alignment = @options[:text_align]
          case text_alignment
          when :left
            @text.x = @style.border_thickness_left + @style.padding_left + @x
          when :center
            if @text.width <= outer_width
              @text.x = @x + outer_width / 2 - @text.width / 2
            else # Act as left aligned
              @text.x = @style.border_thickness_left + @style.padding_left + @x
            end
          when :right
            @text.x = @x + outer_width - (@text.width + @style.border_thickness_right + @style.padding_right)
          end
        end

        update_background
      end

      def value
        @text.text
      end

      def value=(value)
        @text.text = value

        old_width, old_height = width, height
        recalculate

        root.gui_state.request_recalculate if old_width != width || old_height != height

        publish(:changed, self.value)
      end
    end
  end
end