module CyberarmEngine
  class Element
    class Image < Element
      def initialize(path_or_image, options = {}, block = nil)
        super(options, block)
        @path = path_or_image if path_or_image.is_a?(String)

        @image = Gosu::Image.new(path_or_image, retro: @options[:retro], tileable: @options[:tileable]) if @path
        @image = path_or_image unless @path

        @scale_x = 1
        @scale_y = 1
      end

      def render
        @image.draw(
          @style.border_thickness_left + @style.padding_left + @x,
          @style.border_thickness_top + @style.padding_top + @y,
          @z + 2,
          @scale_x, @scale_y, @style.color
        )
      end

      def clicked_left_mouse_button(_sender, _x, _y)
        @block.call(self) if @block

        :handled
      end

      def recalculate
        _width = dimensional_size(@style.width, :width)
        _height = dimensional_size(@style.height, :height)

        if _width && _height
          @scale_x = _width.to_f / @image.width
          @scale_y = _height.to_f / @image.height
        elsif _width
          @scale_x = _width.to_f / @image.width
          @scale_y = @scale_x
        elsif _height
          @scale_y = _height.to_f / @image.height
          @scale_x = @scale_y
        else
          @scale_x = 1
          @scale_y = 1
        end

        @width = _width || @image.width.round * @scale_x
        @height = _height || @image.height.round * @scale_y

        update_background
      end

      def value
        @image
      end

      def value=(path_or_image, retro: false, tileable: false)
        @path = path_or_image if path_or_image.is_a?(String)

        @image = Gosu::Image.new(path_or_image, retro: retro, tileable: tileable) if @path
        @image = path_or_image unless @path

        recalculate
      end

      def path
        @path
      end
    end
  end
end
