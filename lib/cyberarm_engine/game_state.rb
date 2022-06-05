module CyberarmEngine
  class GameState
    include Common

    attr_accessor :options, :global_pause
    attr_reader :game_objects

    def initialize(options = {})
      @options = options
      @game_objects = []
      @global_pause = false
      window.text_input = nil unless options[:preserve_text_input]

      @down_keys = {}
    end

    def setup
    end

    # Called immediately after setup returns.
    # GuiState uses this to set current_theme for ToolTip
    def post_setup
    end

    def draw
      @game_objects.each(&:draw)
    end

    def update
      @game_objects.each(&:update)
    end

    def needs_redraw?
      true
    end

    def drop(filename)
    end

    def gamepad_connected(index)
    end

    def gamepad_disconnected(index)
    end

    def gain_focus
    end

    def lose_focus
    end

    def button_down(id)
      @down_keys[id] = true

      @game_objects.each do |o|
        o.button_down(id)
      end
    end

    def button_up(id)
      @down_keys.delete(id)

      @game_objects.each do |o|
        o.button_up(id)
      end
    end

    def close
      window.close!
    end

    def draw_bounding_box(box)
      x = box.x
      y = box.y
      max_x = box.max_x
      max_y = box.max_y

      color = Gosu::Color.rgba(255, 127, 64, 240)

      # pipe = 4
      # Gosu.draw_rect(x-width, y-height, x+(width*2), y+(height*2), color, Float::INFINITY)
      # puts "BB render: #{x}:#{y} w:#{x.abs+width} h:#{y.abs+height}"
      # Gosu.draw_rect(x, y, x.abs+width, y.abs+height, color, Float::INFINITY)

      # TOP LEFT to BOTTOM LEFT
      Gosu.draw_line(
        x, y, color,
        x, max_y, color,
        Float::INFINITY
      )
      # BOTTOM LEFT to BOTTOM RIGHT
      Gosu.draw_line(
        x, max_y, color,
        max_x, max_y, color,
        Float::INFINITY
      )
      # BOTTOM RIGHT to TOP RIGHT
      Gosu.draw_line(
        max_x, max_y, color,
        max_x, y, color,
        Float::INFINITY
      )
      # TOP RIGHT to TOP LEFT
      Gosu.draw_line(
        max_x, y, color,
        x, y, color,
        Float::INFINITY
      )
    end

    def destroy
      @options.clear
      @game_objects.clear
    end

    def add_game_object(object)
      @game_objects << object
    end
  end
end
