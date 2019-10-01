module CyberarmEngine
  module Theme
    def default(*args)
      value = @options
      args.each do |arg|
        value = value.dig(arg)
      end

      value
    end

    def theme_defaults(options)
      raise "Error" unless self.class.ancestors.include?(CyberarmEngine::Element)
      _theme = THEME
      _theme = _theme.merge(options[:theme]) if options[:theme]
      _theme.delete(:theme) if options[:theme]

      hash = {}
      class_names = self.class.ancestors
      class_names = class_names[0..class_names.index(CyberarmEngine::Element)].map! {|c| c.to_s.split("::").last.to_sym}.reverse!

      class_names.each do |klass|
        next unless data = _theme.dig(klass)
        data.each do |key, value|
          hash.merge!(data)
        end
      end

      deep_merge(hash, options)
    end

    # Derived from Rails Hash#deep_merge!
    # Enables passing partial themes through Element options without issue
    def deep_merge(original, intergrate, &block)
      hash = original.merge(intergrate) do |key, this_val, other_val|
        if this_val.is_a?(Hash) && other_val.is_a?(Hash)
          deep_merge(this_val, other_val, &block)
        elsif block_given?
          block.call(key, this_val, other_val)
        else
          other_val
        end
      end

      return hash
    end

    THEME = {
      Element: {
        x: 0,
        y: 0,
        z: 30,

        width:  nil,
        height: nil,
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
        border_thickness: 1,
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

      Image: { # < Element
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
      },

      Progress: { # < Element
        width: 250,
        height: 36,
        background: 0xff111111,
        fraction_background: [0xffc75e61, 0xffe26623],
        border_thickness: 4,
        border_color: [0xffd59674, 0xffff8746]
      }
    }.freeze
  end
end
