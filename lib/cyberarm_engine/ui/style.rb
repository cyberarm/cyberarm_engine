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

    def initialize(hash = {})
      h = Marshal.load(Marshal.dump(hash))

      h[:default] = {}

      h.each do |key, value|
        next if value.is_a?(Hash)

        h[:default][key] = value
      end

      @hash = h
    end

    def method_missing(method, *args)
      if method.to_s.end_with?("=")
        raise "Did not expect more than 1 argument" if args.size > 1

        @hash[method.to_s.sub("=", "").to_sym] = args.first

      elsif args.empty?
        @hash[method]
      else
        raise ArgumentError, "Did not expect arguments"
      end
    end
  end
end
