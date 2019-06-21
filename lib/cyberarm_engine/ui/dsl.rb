module CyberarmEngine
  module DSL
    def flow(options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = @current_theme
      _container = Flow.new(options, block)
      @containers << _container
      _container.build
      options[:parent].add(_container)
      @containers.pop

      return _container
    end

    def stack(options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = @current_theme
      _container = Stack.new(options, block)
      @containers << _container
      _container.build
      options[:parent].add(_container)
      @containers.pop

      return _container
    end

    def label(text, options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _element = Label.new(text, options, block)
      @containers.last.add(_element)

      return _element
    end

    def button(text, options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _element = Button.new(text, options, block) { if block.is_a?(Proc); block.call; end }
      @containers.last.add(_element)

      return _element
    end

    def edit_line(text, options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _element = EditLine.new(text, options, block)
      @containers.last.add(_element)

      return _element
    end

    def toggle_button(options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _element = ToggleButton.new(options, block)
      @containers.last.add(_element)

      return _element
    end

    def check_box(text, options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _element = CheckBox.new(text, options, block)
      @containers.last.add(_element)

      return _element
    end

    def image(path, options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _element = Image.new(path, options, block)
      @containers.last.add(_element)

      return _element
    end

    def background(color = Gosu::Color::NONE)
      @containers.last.background = color
    end

    # Foreground color, e.g. Text
    def color(color)
      @containers.last.color(color)
    end

    def theme(theme)
      @current_theme = theme
    end

    def current_theme
      @containers.last.options[:theme]
    end
  end
end