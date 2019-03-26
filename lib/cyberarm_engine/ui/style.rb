module CyberarmEngine
  class Style
    def initialize(hash)
      @hash = hash
    end

    def hash
      @hash
    end

    def set(hash)
      @hash.merge!(hash)
    end
  end
end