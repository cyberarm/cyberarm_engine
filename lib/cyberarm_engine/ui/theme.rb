module CyberarmEngine
  module Theme
    def default(*args)
      value = @options
      args.each do |arg|
        value = value.dig(arg)
      end

      value
    end

    def theme_defaults
      raise "Error" unless self.class.ancestors.include?(CyberarmEngine::Element)

      hash = {}
      class_names = self.class.ancestors
      class_names = class_names[0..class_names.index(CyberarmEngine::Element)].map! {|c| c.to_s.split("::").last.to_sym}.reverse!

      class_names.each do |klass|
        next unless data = THEME.dig(klass)
        data.each do |key, value|
          hash.merge!(data)
        end
      end

      hash
    end

    THEME = {
      Element: {
        x: 0,
        y: 0,
        z: 30,

        width:  0,
        height: 0,
        color:     Gosu::Color::WHITE,
        background: Gosu::Color::NONE,
        margin:   0,
        padding:  0,
        border_thickness: 0,
        border_color: Gosu::Color::NONE,
        border_radius: 0,
      },

      Button: { # < Label
        margin:   1,
        padding:  4,
        border_thickness: 4,
        border_color: ["ffd59674".hex, "ffff8746".hex],
        border_radius: 0,
        background: ["ffc75e61".to_i(16), "ffe26623".to_i(16)],

        hover: {
          color: Gosu::Color.rgb(200,200,200),
          background:  ["ffB23E41".to_i(16), "ffFF7C00".to_i(16)],
        },

        active: {
          color: Gosu::Color::BLACK,
          background: ["ffB23E41".to_i(16)]
        }
      },

      EditLine: { # < Button
        type: :text,
        width: 200,
        password_character: "•",
        caret_width: 2,
        caret_color: Gosu::Color::WHITE,
        caret_interval: 500,
      },

      Image: {
        retro: false
      },

      Label: { # < Element
      text_size: 28,
      text_shadow: false,
      font: "Arial",
      margin: 0,
      padding: 2
      },

      ToggleButton: { # < Button
        checkmark: "√"
      }
    }
  end
end