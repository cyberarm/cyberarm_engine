module CyberarmEngine
  class Stack < Container
    include Common

    def initialize(options = {}, block = nil)
      @mode = :stack
      super
    end
  end
end