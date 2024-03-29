module CyberarmEngine
  class Element
    class TextBlock < Element
      def initialize(text, options = {}, block = nil)
        super(options, block)

        @text = Text.new(
          text, font: @options[:font], z: @z, color: @options[:color],
                size: @options[:text_size], shadow: @options[:text_shadow],
                static: @options[:text_static],
                shadow_size: @options[:text_shadow_size],
                shadow_color: @options[:text_shadow_color],
                border: @options[:text_border],
                border_size: @options[:text_border_size],
                border_color: @options[:text_border_color]
        )

        @raw_text = text
      end

      def update
        super

        if @text.textobject.name != safe_style_fetch(:font)
          set_font
          root.gui_state.request_recalculate
        end
      end

      def render
        # Gosu.clip_to is too expensive to always use so check if we actually need it.
        if @text.width > width || @text.height > height
          Gosu.clip_to(@x, @y, width, height) do
            @text.draw
          end
        else
          @text.draw
        end
      end

      def layout
        unless @enabled
          @text.color = @style.disabled[:color]
        else
          @text.color = @style.color
        end

        @width  = 0
        @height = 0

        _width  = dimensional_size(@style.width,  :width)
        _height = dimensional_size(@style.height, :height)

        handle_text_wrapping(_width)

        @width  = _width  || @text.width.floor
        @height = _height || @text.height.floor

        @text.y = @style.border_thickness_top + @style.padding_top + @y
        @text.z = @z + 3

        if (text_alignment = @options[:text_align] || @options[:text_h_align])
          case text_alignment
          when :left
            @text.x = @style.border_thickness_left + @style.padding_left + @x
          when :center
            @text.x = if @text.width <= width
                        @x + width / 2 - @text.width / 2
                      else # Act as left aligned
                        @style.border_thickness_left + @style.padding_left + @x
                      end
          when :right
            @text.x = @x + outer_width - (@text.width + @style.border_thickness_right + @style.padding_right)
          end
        end

        if (vertical_alignment = @options[:text_v_align])
          case vertical_alignment
          when :center
            @text.y = if @text.height <= height
                        @y + height / 2 - @text.height / 2
                      else
                        @style.border_thickness_top + @style.padding_top + @y
                      end
          when :bottom
            @text.y = @y + outer_height - (@text.height + @style.border_thickness_bottom + @style.padding_bottom)
          end
        end

        update_background
      end

      def handle_text_wrapping(max_width)
        max_width ||= @parent&.content_width
        max_width ||= @x - (window.width + noncontent_width)
        wrap_behavior = style.text_wrap
        copy = @raw_text.to_s.dup

        # Only perform text wrapping: if it is enabled, is possible to wrap, and text is too long to fit on one line
        if wrap_behavior != :none && line_width(copy[0]) <= max_width && line_width(copy) > max_width
          breaks = [] # list of indexes to insert a line break
          line_start = 0
          line_end = copy.length

          stalled = false
          stalled_interations = 0
          max_stalled_iterations = 10
          checked_copy_length = line_width(copy[line_start..line_end])

          # find length of lines
          while line_width(copy[line_start..line_end]) > max_width && stalled_interations < max_stalled_iterations
            search_start = line_start
            search_end = line_end

            # Perform a binary search to find length of line
            while search_start < search_end
              midpoint = ((search_start.to_f + search_end) / 2.0).floor

              if line_width(copy[line_start..midpoint]) > max_width
                search_end = midpoint
              else
                search_start = midpoint + 1
              end
            end

            if wrap_behavior == :word_wrap
              word_search_end = search_end
              failed = false

              until(copy[word_search_end].to_s.match(/[[:punct:]]| /))
                word_search_end -= 1

                if word_search_end <= 1 || word_search_end < line_start
                  failed = true
                  break
                end
              end

              line_start = failed ? search_end : word_search_end + 1 # walk in front of punctuation
            else
              line_start = search_end
            end

            breaks << line_start

            # Prevent locking up due to outer while loop text width < max_width check not being satisfied.
            stalled = checked_copy_length == line_width(copy[line_start..line_end])
            checked_copy_length = line_width(copy[line_start..line_end])

            stalled_interations += 1 if stalled
            stalled_interations = 0 unless stalled
          end

          breaks.each_with_index do |pos, index|
            copy.insert(pos + index, "\n") if pos + index >= 0 && pos + index < copy.length
          end
        end

        @text.text = copy
      end

      def line_width(text)
        (@text.textobject.markup_width(text.to_s) + noncontent_width)
      end

      def value
        @raw_text
      end

      def value=(value)
        old_value = @raw_text
        @raw_text = value.to_s.chomp

        old_width = width
        old_height = height

        if old_width != width || old_height != height
          root.gui_state.request_recalculate
        else
          recalculate
        end

        root.gui_state.request_repaint if old_value != @raw_text

        publish(:changed, self.value)
      end
    end

    class Banner < TextBlock
    end

    class Title < TextBlock
    end

    class Subtitle < TextBlock
    end

    class Tagline < TextBlock
    end

    class Caption < TextBlock
    end

    class Para < TextBlock
    end

    class Inscription < TextBlock
    end

    class ToolTip < TextBlock
    end

    class Link < TextBlock
    end
  end
end
