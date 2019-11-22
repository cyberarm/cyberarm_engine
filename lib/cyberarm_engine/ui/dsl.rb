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
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element( Element::Label.new(text, options, block) )
    end

    def button(text, options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element( Element::Button.new(text, options, block) { if block.is_a?(Proc); block.call; end } )
    end

    def edit_line(text, options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element( Element::EditLine.new(text, options, block) )
    end

    def toggle_button(options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element( Element::ToggleButton.new(options, block) )
    end

    def check_box(text, options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element( Element::CheckBox.new(text, options, block) )
    end

    def image(path, options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element( Element::Image.new(path, options, block) )
    end

    def progress(options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element( Element::Progress.new(options, block) )
    end

    def background(color = Gosu::Color::NONE)
      element_parent.style.background = color
    end

    def theme(theme)
      element_parent.options[:theme] = theme
    end

    def current_theme
      element_parent.options[:theme]
    end

    private def add_element(element)
      element_parent.add(element)

      return element
    end

    private def element_parent
      self.is_a?(CyberarmEngine::Element::Container) ? self : @containers.last
    end
  end
end