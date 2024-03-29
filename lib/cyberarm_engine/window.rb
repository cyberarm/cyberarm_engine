module CyberarmEngine
  class Window < Gosu::Window
    include Common

    IMAGES = {}
    SAMPLES = {}
    SONGS = {}

    attr_accessor :show_cursor, :show_stats_plotter
    attr_writer :exit_on_opengl_error
    attr_reader :last_frame_time, :delta_time, :states

    def self.now
      Gosu.milliseconds
    end

    def self.dt
      instance.dt
    end

    def self.instance=(window)
      raise ArgumentError, "Expected window to be a subclass of CyberarmEngine::Window, got: #{window.class}" unless window.is_a?(CyberarmEngine::Window)

      @@instance = window
    end

    def self.instance
      @@instance
    end

    def initialize(width: 800, height: 600, fullscreen: false, update_interval: 1000.0 / 60, resizable: false, borderless: false)
      @show_cursor = false
      @has_focus = false
      @show_stats_plotter = false

      super(width, height, fullscreen: fullscreen, update_interval: update_interval, resizable: resizable, borderless: borderless)
      Window.instance = self

      @last_frame_time = Gosu.milliseconds - 1
      @current_frame_time = Gosu.milliseconds
      @delta_time = @last_frame_time
      self.caption = "CyberarmEngine #{CyberarmEngine::VERSION} #{Gosu.user_languages.join(', ')}"

      @states = []
      @exit_on_opengl_error = false
      preload_default_shaders if respond_to?(:preload_default_shaders)
      @stats_plotter = Stats::StatsPlotter.new(2, 28) # FIXME: Make positioning easy

      setup
    end

    def setup
    end

    def draw
      Stats.frame.start_timing(:draw)

      current_state&.draw
      Stats.frame.start_timing(:engine_stats_renderer)
      @stats_plotter&.draw if @show_stats_plotter
      Stats.frame.end_timing(:engine_stats_renderer)

      Stats.frame.end_timing(:draw)
      Stats.frame.start_timing(:interframe_sleep)
    end

    def update
      # Gosu calls update() then (optionally) draw(),
      # so always end last frame and start next frame when update() is called.
      Stats.frame&.end_timing(:interframe_sleep)
      Stats.end_frame

      Stats.new_frame

      @delta_time = (Gosu.milliseconds - @current_frame_time) * 0.001

      @last_frame_time = Gosu.milliseconds - @current_frame_time
      @current_frame_time = Gosu.milliseconds

      Stats.frame.start_timing(:update)
      current_state&.update
      Stats.frame.end_timing(:update)

      Stats.frame.start_timing(:interframe_sleep) unless needs_redraw?
    end

    def needs_cursor?
      @show_cursor
    end

    def needs_redraw?
      current_state ? current_state.needs_redraw? : true
    end

    def drop(filename)
      current_state&.drop(filename)
    end

    def gamepad_connected(index)
      current_state&.gamepad_connected(index)
    end

    def gamepad_disconnected(index)
      current_state&.gamepad_disconnected(index)
    end

    def gain_focus
      @has_focus = true

      current_state&.gain_focus
    end

    def lose_focus
      @has_focus = false

      current_state&.lose_focus
    end

    def button_down(id)
      super
      current_state&.button_down(id)
    end

    def button_up(id)
      super
      current_state&.button_up(id)
    end

    def close
      current_state ? current_state.close : super
    end

    def dt
      @last_frame_time / 1000.0
    end

    def aspect_ratio
      width / height.to_f
    end

    def exit_on_opengl_error?
      @exit_on_opengl_error
    end

    def push_state(klass, options = {})
      options = { setup: true }.merge(options)

      if klass.instance_of?(klass.class) && klass.respond_to?(:options)
        @states << klass
        klass.setup if options[:setup]
        klass.post_setup if options[:setup]
      else
        @states << klass.new(options) if child_of?(klass, GameState)
        @states << klass.new if child_of?(klass, Element::Container)
        current_state.setup if current_state.instance_of?(klass) && options[:setup]
        current_state.post_setup if current_state.instance_of?(klass) && options[:setup]
      end
    end

    private def child_of?(input, klass)
      return false unless input

      input.ancestors.detect { |c| c == klass }
    end

    def current_state
      @states.last
    end

    def pop_state
      @states.pop

      current_state.request_repaint if current_state&.is_a?(GuiState)
    end

    def shift_state
      @states.shift

      current_state.request_repaint if current_state&.is_a?(GuiState)
    end

    def has_focus?
      @has_focus
    end

    # Sourced from https://gist.github.com/ippa/662583
    def draw_circle(cx, cy, r, z = 9999, color = Gosu::Color::GREEN, step = 10)
      0.step(360, step) do |a1|
        a2 = a1 + step
        draw_line(cx + Gosu.offset_x(a1, r), cy + Gosu.offset_y(a1, r), color, cx + Gosu.offset_x(a2, r),
                  cy + Gosu.offset_y(a2, r), color, z)
      end
    end
  end
end
