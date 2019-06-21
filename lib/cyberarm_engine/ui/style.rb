module CyberarmEngine
  class Style
    def initialize(hash)
      @hash = hash
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