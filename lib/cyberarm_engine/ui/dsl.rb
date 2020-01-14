module CyberarmEngine
  module DSL
    def flow(options = {}, &block)
      container(CyberarmEngine::Element::Flow, options, &block)
    end

    def stack(options = {}, &block)
      container(CyberarmEngine::Element::Stack, options, &block)
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
      $__current_container__
    end

    private def container(klass, options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      _container = klass.new(options, block)

      old_parent = element_parent
      $__current_container__ = _container

      _container.build
      _container.parent.add(_container)

      $__current_container__ = old_parent

      return _container
    end
  end
end