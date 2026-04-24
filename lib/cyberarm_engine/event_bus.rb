module CyberarmEngine
  class EventBus
    Subscriber = Data.define(:event, :listener, :method, :callback)
    @subscribers = []

    def self.subscribe(event, listener = nil, method = nil, &block)
      raise "Subscriber cannot have both a method AND a callback block" if method && block_given?

      subscriber = Subscriber.new(event, listener, method, block)
      @subscribers << subscriber

      subscriber
    end

    def self.unsubscribe(event, listener_or_subscriber)
      @subscribers.delete_if { |s| s.event == event && (s == listener_or_subscriber || s.listener == listener_or_subscriber) }
    end

    def self.unsubscribe!(event)
      @subscribers.delete_if { |s| s.event == event }
    end

    def self.announce(event, *payload)
      subscribers = @subscribers.select { |s| s.event == event }

      subscribers.each do |subscriber|
        subscriber&.listener&.send(subscriber.method, *payload) if subscriber&.method
        subscriber.callback&.call(*payload)
      rescue StandardError => e
        # TODO
        warn "Failed to deliver event (#{event}) to listener (#{subscriber.inspect}): #{e}"
      end
    end

    def self.publish(*args)
      announce(*args)
    end
  end
end
