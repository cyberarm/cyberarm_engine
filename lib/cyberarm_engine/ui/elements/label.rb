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

        @raw_text = text
      end

      def render
        @text.draw
      end

      def clicked_left_mouse_button(sender, x, y)
        @block&.call(self)

        # return :handled
      end

      def recalculate
        @width  = 0
        @height = 0

        _width  = dimensional_size(@style.width,  :width)
        _height = dimensional_size(@style.height, :height)

        handle_text_wrapping(_width)

        @width  = _width  || @text.width.round
        @height = _height || @text.height.round

        @text.y = @style.border_thickness_top + @style.padding_top + @y
        @text.z = @z + 3

        if (text_alignment = @options[:text_align])
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

      def handle_text_wrapping(max_width)
        max_width ||= @parent&.width
        max_width ||= @x - (window.width + noncontent_width)
        wrap_behavior = style.text_wrap
        copy = @raw_text.to_s.dup

        if max_width >= line_width(copy[0]) && line_width(copy) > max_width && wrap_behavior != :none
          breaks = []
          line_start = 0
          line_end   = copy.length

          while line_start != copy.length
            if line_width(copy[line_start...line_end]) > max_width
              line_end = ((line_end - line_start) / 2.0)
            elsif line_end < copy.length && line_width(copy[line_start...line_end + 1]) < max_width
              # To small, grow!
              # TODO: find a more efficient way
              line_end += 1

            else # FOUND IT!
              entering_line_end = line_end.floor
              max_reach = line_end.floor - line_start < 63 ? line_end.floor - line_start : 63
              reach = 0

              if wrap_behavior == :word_wrap
                max_reach.times do |i|
                  reach = i
                  break if copy[line_end.floor - i].to_s.match(/[[:punct:]]|[ ]/)
                end

                puts "Max width: #{max_width}/#{line_width(@raw_text)} Reach: {#{reach}/#{max_reach}} Line Start: #{line_start}/#{line_end.floor} (#{copy.length}|#{@raw_text.length}) [#{entering_line_end}] '#{copy}' {#{copy[line_start...line_end]}}"
                line_end = line_end.floor - reach + 1 if reach != max_reach # Add +1 to walk in front of punctuation
              end

              breaks << line_end.floor
              line_start = line_end.floor
              line_end = copy.length

              break if entering_line_end == copy.length || reach == max_reach
            end
          end

          breaks.each_with_index do |pos, index|
            copy.insert(pos + index, "\n") if pos + index >= 0 && pos + index < copy.length
          end
        end

        @text.text = copy
      end

      def line_width(text)
        (@x + @text.textobject.markup_width(text) + noncontent_width)
      end

      def value
        @raw_text
      end

      def value=(value)
        @raw_text = value.to_s.chomp

        old_width = width
        old_height = height
        recalculate

        root.gui_state.request_recalculate if old_width != width || old_height != height

        publish(:changed, self.value)
      end
    end
  end
end