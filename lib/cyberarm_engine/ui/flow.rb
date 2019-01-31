module CyberarmEngine
  class Flow < Container
    include Common

    def initialize(options = {}, block = nil)
      @mode = :flow
      super
    end
  end
end