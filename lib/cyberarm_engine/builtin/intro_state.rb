module CyberarmEngine
  class IntroState < CyberarmEngine::GameState
    def setup
      @title_size = 56
      @caption_size = 24

      @title = CyberarmEngine::Text.new("", size: @title_size)
      @caption = CyberarmEngine::Text.new("", size: @caption_size)

      @spacer_width = 256

      @cyberarm_engine_logo = generate_proxy("CyberarmEngine", "Powered By")

      @gosu_logo = generate_proxy("Gosu", "Game Library")
      @ruby_logo = generate_proxy("Ruby", "Programming Language")
      @sdl2_logo = generate_proxy("SDL2", "Simple DirectMedia Layer")
    end

    def draw
      Gosu.draw_rect(0, 0, window.width, window.height, 0xff_222222)

      @cyberarm_engine_logo.draw(window.width / 2 - @cyberarm_engine_logo.width / 2, window.height / 2 - @cyberarm_engine_logo.height, 2)

      @gosu_logo.draw(6, window.height - @gosu_logo.height - 6, 2)
      @ruby_logo.draw(window.width / 2 - @ruby_logo.width / 2, window.height - @ruby_logo.height - 6, 2)
      @sdl2_logo.draw(window.width - (@sdl2_logo.width + 6), window.height - @sdl2_logo.height - 6, 2)
    end

    def update
    end

    def generate_proxy(title, caption)
      @title.text = title
      @caption.text = caption

      padding = 6
      spacer_height = 6

      width = @spacer_width + 2 * padding
      height = @title_size + @caption_size + spacer_height + 2 * padding + spacer_height

      Gosu.record(width.ceil, height.ceil) do
        @title.x = (width - padding * 2) / 2 - @title.width / 2
        @title.y = padding
        @title.draw

        Gosu.draw_rect(0, padding + @title_size + padding, @spacer_width, spacer_height, Gosu::Color::WHITE)

        @caption.x =  (width - padding * 2) / 2 - @caption.width / 2
        @caption.y = padding + @title_size + padding + spacer_height + padding
        @caption.draw
      end
    end
  end
end