module CyberarmEngine
  class GameObject
    include Common

    attr_accessor :image, :angle, :position, :velocity, :center_x, :center_y, :scale_x, :scale_y,
                  :color, :mode, :options, :paused, :radius, :last_position
    attr_reader :alpha

    def initialize(options = {})
      $window.current_state.add_game_object(self) if options[:auto_manage] || options[:auto_manage].nil?

      @options = options
      @image = options[:image] ? image(options[:image]) : nil
      x = options[:x] || 0
      y = options[:y] || 0
      z = options[:z] || 0
      @position = Vector.new(x, y, z)
      @velocity = Vector.new
      @last_position = Vector.new
      @angle = options[:angle] || 0

      @center_x = options[:center_x] || 0.5
      @center_y = options[:center_y] || 0.5

      @scale_x  = options[:scale_x] || 1
      @scale_y  = options[:scale_y] || 1

      @color    = options[:color] || Gosu::Color.argb(0xff_ffffff)
      @alpha    = options[:alpha] || 255
      @mode = options[:mode] || :default

      @paused = false
      @speed = 0
      @debug_color = Gosu::Color::GREEN
      @world_center_point = Vector.new(0, 0)

      setup

      @debug_text = Text.new("", color: @debug_color, y: @position.y - (height * scale), z: 9999)
      @debug_text.x = @position.x
      if @radius == 0 || @radius.nil?
        @radius = if options[:radius]
                    options[:radius]
                  else
                    defined?(@image.width) ? ((@image.width + @image.height) / 4) * scale : 1
                  end
      end
    end

    def draw
      if @image
        @image.draw_rot(@position.x, @position.y, @position.z, @angle, @center_x, @center_y, @scale_x, @scale_y,
                        @color, @mode)
      end

      if $debug
        show_debug_heading
        $window.draw_circle(@position.x, @position.y, radius, 9999, @debug_color)
        if @debug_text.text != ""
          $window.draw_rect(@debug_text.x - 10, (@debug_text.y - 10), @debug_text.width + 20, @debug_text.height + 20,
                            Gosu::Color.rgba(0, 0, 0, 200), 9999)
          @debug_text.draw
        end
      end
    end

    def update
    end

    def debug_text(text)
      @debug_text.text = text
      @debug_text.x = @position.x - (@debug_text.width / 2)
      @debug_text.y = @position.y - (@debug_text.height + radius + height)
    end

    def scale
      if @scale_x == @scale_y
        @scale_x
      else
        false
        # maths?
      end
    end

    def scale=(int)
      self.scale_x = int
      self.scale_y = int
      self.radius = ((@image.width + @image.height) / 4) * scale
    end

    def visible
      true
      # if _x_visible
      #   if _y_visible
      #     true
      #   else
      #     false
      #   end
      # else
      #   false
      # end
    end

    def _x_visible
      x.between?(($window.width / 2) - @world_center_point.x, ($window.width / 2) + @world_center_point.x) ||
        x.between?((@world_center_point.x - $window.width / 2), ($window.width / 2) + @world_center_point.x)
    end

    def _y_visible
      y.between?(($window.height / 2) - @world_center_point.y, ($window.height / 2) + @world_center_point.y) ||
        y.between?(@world_center_point.y - ($window.height / 2), ($window.height / 2) + @world_center_point.y)
    end

    def heading(ahead_by = 100, _object = nil, angle_only = false)
      direction = Gosu.angle(@last_position.x, @last_position.x, @position.x, position.y).gosu_to_radians

      _x = @position.x + (ahead_by * Math.cos(direction))
      _y = @position.y + (ahead_by * Math.sin(direction))

      return direction if angle_only
      return Vector.new(_x, _y) unless angle_only
    end

    def show_debug_heading
      _heading = heading
      Gosu.draw_line(@position.x, @position.y, @debug_color, _heading.x, _heading.y, @debug_color, 9999)
    end

    def width
      @image ? @image.width * scale : 0
    end

    def height
      @image ? @image.height * scale : 0
    end

    def pause
      @paused = true
    end

    def unpause
      @paused = false
    end

    def rotate(int)
      self.angle += int
      self.angle %= 360
    end

    def alpha=(int) # 0-255
      @alpha = int
      @alpha = 255 if @alpha > 255
      @color = Gosu::Color.rgba(@color.red, @color.green, @color.blue, int)
    end

    def draw_rect(x, y, width, height, color, z = 0)
      $window.draw_rect(x, y, width, height, color, z)
    end

    def button_up(id)
    end

    def button_down(id)
    end

    def find_closest(game_object_class)
      best_object = nil
      best_distance = 100_000_000_000 # Huge default number

      game_object_class.all.each do |object|
        distance = Gosu.distance(x, y, object.x, object.y)
        if distance <= best_distance
          best_object = object
          best_distance = distance
        end
      end

      best_object
    end

    def look_at(object)
      # TODO: Implement
    end

    def circle_collision?(object)
      distance = Gosu.distance(x, y, object.x, object.y)
      distance <= radius + object.radius
    end

    # Duplication... so DRY.
    def each_circle_collision(object, _resolve_with = :width, &block)
      if object.class != Class && object.instance_of?(object.class)
        $window.current_state.game_objects.select { |i| i.instance_of?(object.class) }.each do |o|
          distance = Gosu.distance(x, y, object.x, object.y)
          block.call(o, object) if distance <= radius + object.radius && block
        end
      else
        list = $window.current_state.game_objects.select { |i| i.instance_of?(object) }
        list.each do |o|
          next if self == o

          distance = Gosu.distance(x, y, o.x, o.y)
          block.call(self, o) if distance <= radius + o.radius && block
        end
      end
    end

    def destroy
      if $window.current_state
        $window.current_state.game_objects.each do |o|
          $window.current_state.game_objects.delete(o) if o.is_a?(self.class) && o == self
        end
      end
    end

    # NOTE: This could be implemented more reliably
    def all
      INSTANCES.select { |i| i.instance_of?(self) }
    end

    def self.each_circle_collision(object, _resolve_with = :width, &block)
      if object.class != Class && object.instance_of?(object.class)
        $window.current_state.game_objects.select { |i| i.instance_of?(self) }.each do |o|
          distance = Gosu.distance(o.x, o.y, object.x, object.y)
          block.call(o, object) if distance <= o.radius + object.radius && block
        end
      else
        lista = $window.current_state.game_objects.select { |i| i.instance_of?(self) }
        listb = $window.current_state.game_objects.select { |i| i.instance_of?(object) }
        lista.product(listb).each do |o, o2|
          next if o == o2

          distance = Gosu.distance(o.x, o.y, o2.x, o2.y)
          block.call(o, o2) if distance <= o.radius + o2.radius && block
        end
      end
    end

    def self.destroy_all
      INSTANCES.clear
      if $window.current_state
        $window.current_state.game_objects.each do |o|
          $window.current_state.game_objects.delete(o) if o.is_a?(self.class)
        end
      end
    end
  end
end
