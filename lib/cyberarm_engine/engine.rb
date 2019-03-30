module CyberarmEngine
  class Engine < Gosu::Window
    IMAGES = {}
    SAMPLES= {}
    SONGS  = {}

    attr_accessor :show_cursor
    attr_reader :current_state, :last_frame_time

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

      @states = []

      setup if defined?(setup)
    end

    def draw
      current_state.draw if current_state
    end

    def update
      current_state.update if current_state
      @last_frame_time = Gosu.milliseconds-@current_frame_time
      @current_frame_time = Gosu.milliseconds
    end

    def needs_cursor?
      @show_cursor
    end

    def dt
      @last_frame_time/1000.0
    end

    def button_down(id)
      current_state.button_down(id) if current_state
    end

    def button_up(id)
      current_state.button_up(id) if current_state
    end

    def push_state(klass, options={})
      if klass.instance_of?(klass.class) && defined?(klass.options)
        @states << klass
      else
        @states << klass.new(options) if child_of?(klass, GameState)
        @states << klass.new if child_of?(klass, Container)
      end
    end

    private def child_of?(input, klass)
      input.ancestors.detect {|c| c == klass}
    end

    def current_state
      @states.last
    end

    def previous_state
      if @states.size > 1 && state = @states[@states.size-2]
        return state
      else
        return nil
      end
    end

    def pop_state
      @states.pop
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