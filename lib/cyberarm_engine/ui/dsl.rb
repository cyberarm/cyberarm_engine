module CyberarmEngine
  module DSL
    def flow(options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _container = Element::Flow.new(options, block)
      @containers << _container
      _container.build
      _container.parent.add(_container)
      @containers.pop

      return _container
    end

    def stack(options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _container = Element::Stack.new(options, block)
      @containers << _container
      _container.build
      _container.parent.add(_container)
      @containers.pop

      return _container
    end

    def label(text, options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _element = Element::Label.new(text, options, block)
      @containers.last.add(_element)

      return _element
    end

    def button(text, options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _element = Element::Button.new(text, options, block) { if block.is_a?(Proc); block.call; end }
      @containers.last.add(_element)

      return _element
    end

    def edit_line(text, options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _element = Element::EditLine.new(text, options, block)
      @containers.last.add(_element)

      return _element
    end

    def toggle_button(options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _element = Element::ToggleButton.new(options, block)
      @containers.last.add(_element)

      return _element
    end

    def check_box(text, options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _element = Element::CheckBox.new(text, options, block)
      @containers.last.add(_element)

      return _element
    end

    def image(path, options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _element = Element::Image.new(path, options, block)
      @containers.last.add(_element)

      return _element
    end

    def progress(options = {}, &block)
      options[:parent] = @containers.last
      options[:theme] = current_theme
      _element = Element::Progress.new(options, block)
      @containers.last.add(_element)

      return _element
    end

    def background(color = Gosu::Color::NONE)
      @containers.last.style.background = color
    end

    def theme(theme)
      @containers.last.options[:theme] = theme
    end

    def current_theme
      @containers.last.options[:theme]
    end
  end
end