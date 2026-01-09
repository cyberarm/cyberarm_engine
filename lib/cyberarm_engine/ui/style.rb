module Gosu
  class Color
    def _dump(_level)
      [
        "%02X" % alpha,
        "%02X" % red,
        "%02X" % green,
        "%02X" % blue
      ].join
    end

    def self._load(hex)
      argb(hex.to_i(16))
    end
  end
end

module CyberarmEngine
  class Style
    attr_reader :hash

    %i[
      x y z width height min_width min_height max_width max_height color background
      background_image background_image_mode background_image_color
      background_nine_slice background_nine_slice_mode background_nine_slice_color background_nine_slice_from_edge
      background_nine_slice_left background_nine_slice_top background_nine_slice_right background_nine_slice_bottom
      border_color border_color_left border_color_right border_color_top border_color_bottom
      border_thickness border_thickness_left border_thickness_right border_thickness_top border_thickness_bottom
      padding padding_left padding_right padding_top padding_bottom
      margin margin_left margin_right margin_top margin_bottom
      background_canvas background_nine_slice_canvas background_image_canvas border_canvas

      fraction_background scroll fill text_wrap v_align h_align delay tag
      image_width image_height

      default hover active disabled
    ].each do |item|
      define_method(item) do
        @hash[item]
      end
      define_method(:"#{item}=") do |value|
        @hash[item] = value
      end
    end

    def initialize(hash = {})
      h = hash
      # h = Marshal.load(Marshal.dump(hash))

      h[:default] = {}

      h.each do |key, value|
        next if value.is_a?(Hash)

        h[:default][key] = value
      end

      @hash = h
    end
  end
end
