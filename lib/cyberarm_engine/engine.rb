module CyberarmEngine
  class Engine < Gosu::Window
    attr_accessor :show_cursor
    attr_reader :current_game_state, :last_game_state, :last_frame_time

    def self.now
      Gosu.milliseconds
    end

    def self.dt
      $window.last_frame_time/1000.0
    end

    def initialize(width = 800, height = 600, fullscreen = false, update_interval = 1000.0/60)
      @show_cursor = false

      super(width, height, fullscreen, update_interval)
      $window = self
      @last_frame_time = Gosu.milliseconds-1
      @current_frame_time = Gosu.milliseconds
      self.caption = "CyberarmEngine #{CyberarmEngine::VERSION} #{Gosu.language}"

      setup if defined?(setup)
    end

    def draw
      if @current_game_state.is_a?(GameState)
        @current_game_state.draw
      end
    end

    def update
      if @current_game_state.is_a?(GameState)
        @current_game_state.update
      end
      @last_frame_time = Gosu.milliseconds-@current_frame_time
      @current_frame_time = Gosu.milliseconds
    end

    def needs_cursor?
      @show_cursor
    end

    def dt
      @last_frame_time/1000.0
    end

    def button_up(id)
      @current_game_state.button_up(id) if @current_game_state
    end

    def push_game_state(klass, options={})
      @last_game_state = @current_game_state if @current_game_state
      if klass.instance_of?(klass.class) && defined?(klass.options)
        @current_game_state = klass
      else
        klass.new(options)
      end
    end

    def set_game_state(klass_instance)
      @current_game_state = klass_instance
    end

    def previous_game_state
      # current_game_state = @current_game_state
      # @current_game_state = @last_frame_time
      # @last_game_state = current_game_state
      @last_game_state
    end

    # Sourced from https://gist.github.com/ippa/662583
    def draw_circle(cx,cy,r, z = 9999,color = Gosu::Color::GREEN, step = 10)
      0.step(360, step) do |a1|
        a2 = a1 + step
        draw_line(cx + Gosu.offset_x(a1, r), cy + Gosu.offset_y(a1, r), color, cx + Gosu.offset_x(a2, r), cy + Gosu.offset_y(a2, r), color, z)
      end
    end
  end
end