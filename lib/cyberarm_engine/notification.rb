module CyberarmEngine
  class Notification
    WIDTH = 500
    HEIGHT = 64
    EDGE_WIDTH = 8
    TRANSITION_DURATION = 750
    PADDING = 8

    TTL_LONG   = 5_000
    TTL_MEDIUM = 3_250
    TTL_SHORT  = 1_500
    TIME_TO_LIVE = TTL_MEDIUM

    BACKGROUND_COLOR = Gosu::Color.new(0xaa313533)
    EDGE_COLOR    = Gosu::Color.new(0xaa010101)
    ICON_COLOR    = Gosu::Color.new(0xddffffff)
    TITLE_COLOR   = Gosu::Color.new(0xddffffff)
    TAGLINE_COLOR = Gosu::Color.new(0xddaaaaaa)

    TITLE_SIZE = 28
    TAGLINE_SIZE = 18
    ICON_SIZE = HEIGHT - PADDING * 2

    TITLE_FONT = Gosu::Font.new(TITLE_SIZE, bold: true)
    TAGLINE_FONT = Gosu::Font.new(TAGLINE_SIZE)

    PRIORITY_HIGH   = 1.0
    PRIORITY_MEDIUM = 0.5
    PRIORITY_LOW    = 0.0

    LINEAR_TRANSITION = :linear
    EASE_IN_OUT_TRANSITION = :ease_in_out

    attr_reader :priority, :title, :tagline, :icon, :time_to_live, :transition_duration, :transition_type
    def initialize(
      host:, priority:, title:, title_color: TITLE_COLOR, tagline: "", tagline_color: TAGLINE_COLOR, icon: nil, icon_color: ICON_COLOR,
      edge_color: EDGE_COLOR, background_color: BACKGROUND_COLOR, time_to_live: TIME_TO_LIVE, transition_duration: TRANSITION_DURATION,
      transition_type: EASE_IN_OUT_TRANSITION
    )
      @host = host

      @priority = priority
      @title = title
      @title_color = title_color
      @tagline = tagline
      @tagline_color = tagline_color
      @icon = icon
      @icon_color = icon_color
      @edge_color = edge_color
      @background_color = background_color
      @time_to_live = time_to_live
      @transition_duration = transition_duration
      @transition_type = transition_type

      @icon_scale = ICON_SIZE.to_f / @icon.width if @icon
    end

    def draw
      Gosu.draw_rect(0, 0, WIDTH, HEIGHT, @background_color)

      if @host.edge == :top
        Gosu.draw_rect(0, HEIGHT - EDGE_WIDTH, WIDTH, EDGE_WIDTH, @edge_color)
        @icon.draw(EDGE_WIDTH + PADDING, PADDING, 0, @icon_scale, @icon_scale, @icon_color) if @icon

      elsif @host.edge == :bottom
        Gosu.draw_rect(0, 0, WIDTH, EDGE_WIDTH, @edge_color)
        @icon.draw(EDGE_WIDTH + PADDING, PADDING, 0, @icon_scale, @icon_scale, @icon_color) if @icon

      elsif @host.edge == :right
        Gosu.draw_rect(0, 0, EDGE_WIDTH, HEIGHT, @edge_color)
        @icon.draw(EDGE_WIDTH + PADDING, PADDING, 0, @icon_scale, @icon_scale, @icon_color) if @icon

      else
        Gosu.draw_rect(WIDTH - EDGE_WIDTH, 0, EDGE_WIDTH, HEIGHT, @edge_color)
        @icon.draw(PADDING, PADDING, 0, @icon_scale, @icon_scale, @icon_color) if @icon
      end

      icon_space = @icon ? ICON_SIZE + PADDING : 0
      TITLE_FONT.draw_text(@title, PADDING + EDGE_WIDTH + icon_space, PADDING, 0, 1, 1, @title_color)
      TAGLINE_FONT.draw_text(@tagline, PADDING + EDGE_WIDTH + icon_space, PADDING + TITLE_FONT.height, 0, 1, 1, @tagline_color)
    end
  end
end