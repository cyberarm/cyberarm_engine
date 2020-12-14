module CyberarmEngine
  class ConfigFile
    def initialize(file:)
      @file = file

      if File.exist?(@file)
        deserialize
      else
        @data = {}
      end
    end

    def []=(*keys, value)
      last_key = keys.last

      if keys.size == 1
        hash = @data
      else
        keys.pop
        hash = @data[keys.shift] ||= {}

        keys.each do |key|
          hash = hash[key] ||= {}
        end
      end

      hash[last_key] = value
    end

    def get(*keys)
      @data.dig(*keys)
    end

    def serialize
      JSON.dump(@data)
    end

    def deserialize
      @data = JSON.parse(File.read(@file), symbolize_names: true)
    end

    def save!
      File.open(@file, "w") { |f| f.write(serialize) }
    end
  end
end
