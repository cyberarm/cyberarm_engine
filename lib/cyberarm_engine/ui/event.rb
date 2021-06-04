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

      was_handled = false

      was_handled = true if respond_to?(event) && (send(event, self, *args) == :handled)

      @event_handler[event].reverse_each do |handler|
        if handler.call(self, *args) == :handled
          was_handled = true
          break
        end
      end

      return :handled if was_handled

      parent.publish(event, *args) if parent
      nil
    end

    def event(event)
      @event_handler ||= {}
      @event_handler[event] ||= []
    end
  end

  class Subscription
    attr_reader :publisher, :event, :handler

    def initialize(publisher, event, handler)
      @publisher = publisher
      @event = event
      @handler = handler
    end

    def unsubscribe
      @publisher.unsubscribe(self)
    end
  end
end
