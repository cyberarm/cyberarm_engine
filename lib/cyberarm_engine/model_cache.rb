module CyberarmEngine
  module ModelCache
    CACHE = {}

    def self.find_or_cache(manifest:)
      model_file = manifest.file_path + "/model/#{manifest.model}"

      type = File.basename(model_file).split(".").last.to_sym

      if model = load_model_from_cache(type, model_file)
        model
      else
        model = CyberarmEngine::Model.new(file_path: model_file)
        cache_model(type, model_file, model)

        model
      end
    end

    def self.load_model_from_cache(type, model_file)
      return CACHE[type][model_file] if CACHE[type].is_a?(Hash) && (CACHE[type][model_file])

      false
    end

    def self.cache_model(type, model_file, model)
      CACHE[type] = {} unless CACHE[type].is_a?(Hash)
      CACHE[type][model_file] = model
    end
  end
end
