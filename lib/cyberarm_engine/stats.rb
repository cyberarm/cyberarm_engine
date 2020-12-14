module CyberarmEngine
  class Stats
    @@hash = {
      gui_recalculations_last_frame: 0
    }

    def self.get(key)
      @@hash.dig(key)
    end

    def self.increment(key, n)
      @@hash[key] += n
    end

    def self.clear
      @@hash.each do |key, _value|
        @@hash[key] = 0
      end
    end
  end
end
