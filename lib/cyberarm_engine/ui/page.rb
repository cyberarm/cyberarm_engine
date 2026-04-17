module CyberarmEngine
  class Page
    include CyberarmEngine::DSL
    include CyberarmEngine::Common

    attr_reader :parent

    def initialize(parent:)
      @parent = parent

      @options = {}
    end

    def options=(options)
      @options = options
    end

    def setup
    end

    def focus
    end

    def blur
    end

    def draw
    end

    def update
    end

    def button_down(id)
    end

    def button_up(id)
    end
  end
end
