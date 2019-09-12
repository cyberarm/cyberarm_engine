module CyberarmEngine
  class Element
    class Image < Element
      def initialize(path, options = {}, block = nil)
        super(options, block)
        @path = path

        @image = Gosu::Image.new(path, retro: @options[:image_retro])
        @scale_x, @scale_y = 1, 1
      end

      def render
        @image.draw(
          @style.border_thickness_left + @style.padding_left + @x,
          @style.border_thickness_top + @style.padding_top + @y,
          @z + 2,
          @scale_x, @scale_y) # TODO: Add color support?
      end

      def clicked_left_mouse_button(sender, x, y)
        @block.call(self) if @block

        return :handled
      end

      def recalculate
        _width = dimensional_size(@style.width, :width)
        _height= dimensional_size(@style.height,:height)

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
          @scale_x, @scale_y = 1, 1
        end

        @width = _width  ? _width  : @image.width.round * @scale_x
        @height= _height ? _height : @image.height.round * @scale_y
      end

      def value
        @path
      end
    end
  end
end