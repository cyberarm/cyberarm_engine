module CyberarmEngine
  # result pattern
  class Result
    attr_accessor :error, :data

    def initialize(data: nil, error: nil)
      @data = data
      @error = error
    end

    def okay?
      !@error
    end

    def error?
      @error || @data.nil?
    end
  end
end

