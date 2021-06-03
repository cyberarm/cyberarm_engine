module CyberarmEngine
  class IntroState < CyberarmEngine::GameState
    def setup
      @display_width  = 800
      @display_height = 600

      @title_size = 56
      @caption_size = 24

      @title = CyberarmEngine::Text.new("", size: @title_size, shadow_color: 0xaa_222222)
      @caption = CyberarmEngine::Text.new("", size: @caption_size, shadow_color: 0xaa_222222)

      @spacer_width = 256
      @spacer_height = 6
      @padding = 6

      @cyberarm_engine_logo = get_image "#{CYBERARM_ENGINE_ROOT_PATH}/assets/textures/logo.png"

      @gosu_logo = generate_proxy("Gosu",     "Game Library",         0xff_111111)
      @ruby_logo = generate_proxy("Ruby",     "Programming Language", 0xff_880000)
      @opengl_logo = generate_proxy("OpenGL", "Graphics API",         0xff_5586a4) if defined?(OpenGL)

      base_time = Gosu.milliseconds

      @born_time = Gosu.milliseconds
      @continue_after = 5_000

      @animators = [
        Animator.new(start_time: base_time += 1000, duration: 100,   from: 0.0, to: 1.0, tween: :ease_in_out),
        Animator.new(start_time: base_time += -500, duration: 1_000, from: 0.0, to: 1.0, tween: :ease_in_out),
        Animator.new(start_time: base_time += 500,  duration: 1_000, from: 0.0, to: 1.0, tween: :ease_in_out),
        Animator.new(start_time: base_time += 500,  duration: 1_000, from: 0.0, to: 1.0, tween: :ease_in_out),
        Animator.new(start_time: base_time +  500,  duration: 1_000, from: 0.0, to: 1.0, tween: :ease_in_out),
        Animator.new(start_time: Gosu.milliseconds + @continue_after - 1_000,  duration: 1_000, from: 0.0, to: 1.0, tween: :ease_in_out),

        Animator.new(start_time: Gosu.milliseconds + 250, duration: 500, from: 0.0, to: 1.0, tween: :swing_to) # CyberarmEngine LOGO
      ]
    end

    def draw
      Gosu.draw_rect(0, 0, window.width, window.height, 0xff_222222)

      scale = (@display_width - @padding * 2).to_f / @cyberarm_engine_logo.width * @animators.last.transition

      @cyberarm_engine_logo.draw_rot(
        window.width / 2,
        (window.height) / 2 - @cyberarm_engine_logo.height / 2 - @padding * 2,
        2,
        0,
        0.5,
        0.5,
        scale,
        scale
      )

      Gosu.draw_rect(
        window.width / 2 - (@display_width / 2 + @padding),
        window.height / 2 - @spacer_height / 2,
        @display_width + @padding,
        @spacer_height * @animators[0].transition,
        Gosu::Color::WHITE
      )

      @title.x = window.width / 2 - @title.text_width / 2
      @title.y = (window.height / 2 + (@spacer_height / 2) + @padding) * @animators[1].transition
      @title.text = "Powered By"

      Gosu.clip_to(0, window.height / 2 + (@spacer_height / 2), window.width, @title.height) do
        @title.draw
      end

      y = @title.y + @title.height * 2

      Gosu.clip_to(0, y, window.width, @gosu_logo.height) do
        Gosu.translate(@opengl_logo.nil? ? @ruby_logo.width / 2 : 0, 0) do
          @gosu_logo.draw(
            window.width.to_f / 2 - @ruby_logo.width / 2 - (@ruby_logo.width - @padding),
            y * @animators[2].transition,
            2
          )
          @ruby_logo.draw(
            window.width.to_f / 2 - @ruby_logo.width / 2,
            y * @animators[3].transition,
            2
          )
          @opengl_logo&.draw(
            window.width.to_f / 2 - @ruby_logo.width / 2 + (@ruby_logo.width - @padding),
            y * @animators[4].transition,
            2
          )
        end
      end

      Gosu.draw_rect(0, 0, window.width, window.height, Gosu::Color.rgba(0, 0, 0, 255 * @animators[5].transition), 10_000)
    end

    def update
      @animators.each(&:update)

      return unless Gosu.milliseconds - @born_time >= @continue_after

      pop_state
      push_state(@options[:forward], @options[:forward_options] || {}) if @options[:forward]
    end

    def button_down(_id)
      @continue_after = 0
    end

    def generate_proxy(title, caption, color_hint)
      @title.text = title
      @caption.text = caption

      width = @spacer_width + 2 * @padding
      height = @title_size + @caption_size + @spacer_height + 2 * @padding + @spacer_height

      Gosu.record(width.ceil, height.ceil) do
        @title.x = (width - @padding * 2) / 2 - @title.text_width / 2
        @title.y = @padding
        @title.draw

        Gosu.draw_rect(0, @padding + @title_size + @padding, @spacer_width, @spacer_height, Gosu::Color::WHITE)
        Gosu.draw_rect(1, @padding + @title_size + @padding + 1, @spacer_width - 2, @spacer_height - 2, color_hint)

        @caption.x =  (width - @padding * 2) / 2 - @caption.text_width / 2
        @caption.y = @padding + @title_size + @padding + @spacer_height + @padding
        @caption.draw
      end
    end
  end
end