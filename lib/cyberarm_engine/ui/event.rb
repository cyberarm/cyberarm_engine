module CyberarmEngine
  module Event # Gets included into Element
    def subscribe(event, method = nil, &block)
      handler = method || block
      @event_handler[event] << handler

      Subscription.new(self, event, handler)
    end

    def unsubscribe(subscription)
    end

    def publish(event, *args)
      raise ArgumentError, "#{self.class} does not handle #{event.inspect}" unless @event_handler.include?(event)

      return unless enabled?

      if respond_to?(event)
        return :handled if send(event, self, *args) == :handled
      end

      @event_handler[event].reverse_each do |handler|
        return :handled if handler.call(self, *args) == :handled
      end

      parent.publish(event, *args) if parent
      return nil
    end

    def event(event)
      @event_handler ||= Hash.new
      @event_handler[event] ||= []
    end
  end

  class Subscription
    attr_reader :publisher, :event, :handler

    def initialize(publisher, event, handler)
      @publisher, @event, @handler = publisher, event, handler
    end

    def unsubscribe
      @publisher.unsubscribe(self)
    end
  end
end