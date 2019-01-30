module CyberarmEngine
  class GameState
    include Common

    SCALE_X_BASE = 1920.0
    SCALE_Y_BASE = 1080.0
    attr_accessor :options, :global_pause
    attr_reader :game_objects

    def initialize(options={})
      @options = options unless @options
      @game_objects = []
      @global_pause = false

      setup
    end

    def setup
    end

    def draw
      @game_objects.each do |o|
        o.draw if o.visible
      end
    end

    def update
      @game_objects.each do |o|
        unless o.paused || @global_pause
          o.update
          o.update_debug_text if $debug
        end
      end
    end

    def destroy
      @options = nil
      @game_objects = nil
    end

    def button_up(id)
      @game_objects.each do |o|
        o.button_up(id) unless o.paused
      end
    end

    def add_game_object(object)
      @game_objects << object
    end
  end
end