module CyberarmEngine
  module Event
    def subscribe(event, method = nil, &block)
    end

    def unsubscribe(event)
    end

    def publish(event, *args)
      # block.call(*args)
    end

    def event(event)
      @event_handler ||= Hash.new
      @event_handler[event] ||= []
    end
  end

  class Subscription
  end
end