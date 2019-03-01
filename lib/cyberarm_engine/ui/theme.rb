module CyberarmEngine
  module Theme
    DEFAULTS = {
      x: 0,
      y: 0,
      z: 30,

      width: 0,
      height: 0
    }

    THEME = {
      stroke:     Gosu::Color::WHITE,
      fill:       Gosu::Color::NONE,
      background: Gosu::Color::NONE,
      checkmark: "√", # √

      margin:   0,
      padding:  5,

      element_background: Gosu::Color.rgb(12,12,12),

      interactive_stroke:            Gosu::Color::WHITE,
      interactive_active_stroke:     Gosu::Color::GRAY,

      interactive_background:        Gosu::Color::GRAY,
      interactive_hover_background:  Gosu::Color.rgb(100, 100, 100),
      interactive_active_background: Gosu::Color.rgb(50, 50, 50),
      interactive_border_size: 1,

      edit_line_width: 200,
      edit_line_password_character: "•", # •
      caret_width: 2,
      caret_color: Gosu::Color.rgb(50,50,25),
      caret_interval: 500,

      image_retro: false,

      text_size: 22,
      text_shadow: true,
      font: "Sans Serif"
    }
  end
end