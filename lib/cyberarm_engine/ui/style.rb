module Gosu
  class Color
    def _dump(level)
      [
        "%02X" % self.alpha,
        "%02X" % self.red,
        "%02X" % self.green,
        "%02X" % self.blue
      ].join
    end

    def self._load(hex)
      argb(hex.to_i(16))
    end
  end
end

module CyberarmEngine
  class Style
    def initialize(hash = {})
      @hash = Marshal.load(Marshal.dump(hash))
    end

    def method_missing(method, *args, &block)
      if method.to_s.end_with?("=")
        raise "Did not expect more than 1 argument" if args.size > 1
        return @hash[method.to_s.sub("=", "").to_sym] = args.first

      elsif args.size == 0
        return @hash[method]

      else
        raise ArgumentError, "Did not expect arguments"
      end
    end
  end
end