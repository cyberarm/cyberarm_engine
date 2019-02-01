module CyberarmEngine
  class GameState
    include Common
    include DSL

    attr_accessor :options, :global_pause, :active_container, :active_grid
    attr_reader :game_objects, :containers

    def initialize(options={})
      @options = options
      @game_objects = []
      @global_pause = false

      @root_container = Stack.new(x: 0, y: 0, width: $window.width, height: $window.height)
      @game_objects << @root_container
      @containers     = [@root_container]

      setup
    end

    def setup
    end

    def draw
      @game_objects.each(&:draw)
    end

    def update
      @game_objects.each(&:update)
    end

    def destroy
      @options = nil
      @game_objects = nil
    end

    def button_up(id)
      @game_objects.each do |o|
        o.button_up(id)
      end
    end

    def add_game_object(object)
      @game_objects << object
    end
  end
end