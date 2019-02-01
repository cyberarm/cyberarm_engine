module CyberarmEngine
  module DSL
    def flow(options = {}, &block)
      puts "Flow"
      options[:parent] = @containers.last
      _container = Flow.new(options, block)
      @containers << _container
      _container.build
      options[:parent].add_child(_container)
      @containers.pop

      return _container
    end

    def stack(options = {}, &block)
      puts "Stack"
      options[:parent] = @containers.last
      _container = Stack.new(options, block)
      @containers << _container
      _container.build
      options[:parent].add_child(_container)
      @containers.pop

      return _container
    end

    def label(text, options = {}, &block)
      options[:parent] = @containers.last
      _element = Label.new(text, options, block)
      @containers.last.add(_element)

      return _element
    end

    def button(text, options = {}, &block)
      options[:parent] = @containers.last
      _element = Button.new(text, options, block) { if block.is_a?(Proc); block.call; end }
      @containers.last.add(_element)

      return _element
    end

    def edit_line(text, options = {}, &block)
      options[:parent] = @containers.last
      _element = EditLine.new(text, options, block)
      @containers.last.add(_element)

      return _element
    end

    def check_box(options = {}, &block)
      options[:parent] = @containers.last
      _element = CheckBox.new(options, block)
      @containers.last.add(_element)

      return _element
    end

    def background(color = Gosu::Color::NONE)
      @containers.last.background_color = color
    end

    # Foreground color, e.g. Text
    def stroke(color)
      @containers.last.stroke(color)
    end

    # Element background color
    def fill(color)
      @containers.last.fill(color)
    end
  end
end