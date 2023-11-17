module CyberarmEngine
  class NotificationManager
    EDGE_TOP = :top
    EDGE_BOTTOM = :bottom
    EDGE_RIGHT = :right
    EDGE_LEFT = :left

    MODE_DEFAULT = :slide
    MODE_CIRCLE  = :circle

    attr_reader :edge, :mode, :max_visible, :notifications
    def initialize(edge: EDGE_RIGHT, mode: MODE_DEFAULT, window:, max_visible: 1)
      @edge = edge
      @mode = mode
      @window = window
      @max_visible = max_visible

      @notifications = []
      @drivers = []
      @slots = Array.new(max_visible, nil)
    end

    def draw
      @drivers.each do |driver|
        case @edge
        when :left, :right
          x = @edge == :right ? @window.width + driver.x : -Notification::WIDTH + driver.x
          y = driver.y + Notification::HEIGHT / 2

          Gosu.translate(x, y + (Notification::HEIGHT + Notification::PADDING) * driver.slot) do
            driver.draw
          end

        when :top, :bottom
          x = @window.width / 2 - Notification::WIDTH / 2
          y = @edge == :top ? driver.y - Notification::HEIGHT : @window.height + driver.y
          slot_position = (Notification::HEIGHT + Notification::PADDING) * driver.slot
          slot_position *= -1 if @edge == :bottom

          Gosu.translate(x, y + slot_position) do
            driver.draw
          end
        end
      end
    end

    def update
      show_next_notification if @drivers.size < @max_visible
      @drivers.each do |driver|
        if driver.done?
          @slots[driver.slot] = nil
          @drivers.delete(driver)
        end
      end

      @drivers.each(&:update)
    end

    def show_next_notification
      notification = @notifications.sort { |n| n.priority }.reverse.shift
      return unless notification
      return if available_slot_index < lowest_used_slot
      @notifications.delete(notification)

      @drivers << Driver.new(edge: @edge, mode: @mode, notification: notification, slot: available_slot_index)
      slot = @slots[available_slot_index] = @drivers.last
    end

    def available_slot_index
      @slots.each_with_index do |slot, i|
        return i unless slot
      end

      return -1
    end

    def lowest_used_slot
      @slots.each_with_index do |slot, i|
        return i if slot
      end

      return -1
    end

    def highest_used_slot
      _slot = -1
      @slots.each_with_index do |slot, i|
        _slot = i if slot
      end

      return _slot
    end

    def create_notification(**args)
      notification = Notification.new(host: self, **args)
      @notifications << notification
    end

    class Driver
      attr_reader :x, :y, :notification, :slot
      def initialize(edge:, mode:, notification:, slot:)
        @edge = edge
        @mode = mode
        @notification = notification
        @slot = slot

        @x, @y = 0, 0
        @delta = Gosu.milliseconds
        @accumulator = 0.0

        @born_at = Gosu.milliseconds
        @duration_completed_at = Float::INFINITY
        @transition_completed_at = Float::INFINITY
      end

      def transition_in_complete?
        Gosu.milliseconds - @born_at >= @notification.transition_duration
      end

      def duration_completed?
        Gosu.milliseconds - @transition_completed_at >= @notification.time_to_live
      end

      def done?
        Gosu.milliseconds - @duration_completed_at >= @notification.transition_duration
      end

      def draw
        ratio = 0.0

        if not transition_in_complete?
          ratio = animation_ratio
        elsif transition_in_complete? and not duration_completed?
          ratio = 1.0
        elsif duration_completed?
          ratio = 1.0 - animation_ratio
        end

        case @mode
        when MODE_DEFAULT
          Gosu.clip_to(0, 0, Notification::WIDTH, Notification::HEIGHT * ratio) do
            @notification.draw
          end
        when MODE_CIRCLE
          half = Notification::WIDTH / 2

          Gosu.clip_to(half - (half * ratio), 0, Notification::WIDTH * ratio, Notification::HEIGHT) do
            @notification.draw
          end
        end
      end

      def update
        case @mode
        when MODE_DEFAULT
          update_default
        when MODE_CIRCLE
          update_circle
        end

        @accumulator += Gosu.milliseconds - @delta
        @delta = Gosu.milliseconds
      end


      def update_default
        case @edge
        when :left, :right
          if not transition_in_complete? # Slide In
            @x = @edge == :right ? -x_offset : x_offset
          elsif transition_in_complete? and not duration_completed?
            @x = @edge == :right ? -Notification::WIDTH : Notification::WIDTH if @x.abs != Notification::WIDTH
            @transition_completed_at = Gosu.milliseconds if @transition_completed_at == Float::INFINITY
            @accumulator = 0.0
          elsif duration_completed? # Slide Out
            @x = @edge == :right ? x_offset - Notification::WIDTH : Notification::WIDTH - x_offset
            @x = 0 if @edge == :left and @x <= 0
            @x = 0 if @edge == :right and @x >= 0
            @duration_completed_at = Gosu.milliseconds if @duration_completed_at == Float::INFINITY
          end

        when :top, :bottom
          if not transition_in_complete? # Slide In
            @y = @edge == :top ? y_offset : -y_offset
          elsif transition_in_complete? and not duration_completed?
            @y = @edge == :top ? Notification::HEIGHT : -Notification::HEIGHT if @x.abs != Notification::HEIGHT
            @transition_completed_at = Gosu.milliseconds if @transition_completed_at == Float::INFINITY
            @accumulator = 0.0
          elsif duration_completed? # Slide Out
            @y = @edge == :top ? Notification::HEIGHT - y_offset : y_offset - Notification::HEIGHT
            @y = 0 if @edge == :top and @y <= 0
            @y = 0 if @edge == :bottom and @y >= 0
            @duration_completed_at = Gosu.milliseconds if @duration_completed_at == Float::INFINITY
          end
        end
      end

      def update_circle
        case @edge
        when :top, :bottom
          @y = @edge == :top ? Notification::HEIGHT : -Notification::HEIGHT
        when :left, :right
          @x = @edge == :right ? -Notification::WIDTH : Notification::WIDTH
        end

        if transition_in_complete? and not duration_completed?
          @transition_completed_at = Gosu.milliseconds if @transition_completed_at == Float::INFINITY
          @accumulator = 0.0
        elsif duration_completed?
          @duration_completed_at = Gosu.milliseconds if @duration_completed_at == Float::INFINITY
        end
      end

      def animation_ratio
        x = (@accumulator / @notification.transition_duration)

        case @notification.transition_type
        when Notification::LINEAR_TRANSITION
          x.clamp(0.0, 1.0)
        when Notification::EASE_IN_OUT_TRANSITION # https://easings.net/#easeInOutQuint
          (x < 0.5 ? 16 * x * x * x * x * x : 1 - ((-2 * x + 2) ** 5) / 2).clamp(0.0, 1.0)
        end
      end

      def x_offset
        if not transition_in_complete? or duration_completed?
          Notification::WIDTH * animation_ratio
        else
          0
        end
      end

      def y_offset
        if not transition_in_complete? or duration_completed?
          Notification::HEIGHT * animation_ratio
        else
          0
        end
      end
    end
  end
end