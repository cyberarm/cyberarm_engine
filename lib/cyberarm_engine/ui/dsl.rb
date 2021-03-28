module CyberarmEngine
  module DSL
    def flow(options = {}, &block)
      container(CyberarmEngine::Element::Flow, options, &block)
    end

    def stack(options = {}, &block)
      container(CyberarmEngine::Element::Stack, options, &block)
    end

    # TODO: Remove in version 0.16.0+
    def label(text, options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element(Element::TextBlock.new(text, options, block))
    end

    [
      "Banner",
      "Title",
      "Subtitle",
      "Tagline",
      "Caption",
      "Para",
      "Inscription",
      "Link"
    ].each do |const|
      define_method(:"#{const.downcase}") do |text, options = {}, &block|
        options[:parent] = element_parent
        options[:theme] = current_theme

        add_element(Element.const_get(const).new(text, options, block))
      end
    end

    def button(text, options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element(Element::Button.new(text, options, block) { block.call if block.is_a?(Proc) })
    end

    def list_box(options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element(Element::ListBox.new(options, block) { block.call if block.is_a?(Proc) })
    end

    def edit_line(text, options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element(Element::EditLine.new(text, options, block))
    end

    def edit_box(text, options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element(Element::EditBox.new(text, options, block))
    end

    def toggle_button(options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element(Element::ToggleButton.new(options, block))
    end

    def check_box(text, options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element(Element::CheckBox.new(text, options, block))
    end

    def image(path, options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element(Element::Image.new(path, options, block))
    end

    def progress(options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element(Element::Progress.new(options, block))
    end

    def slider(options = {}, &block)
      options[:parent] = element_parent
      options[:theme] = current_theme

      add_element(Element::Slider.new(options, block))
    end

    def background(color = Gosu::Color::NONE)
      element_parent.style.default[:background] = color
    end

    def theme(theme)
      element_parent.options[:theme] = theme
    end

    def current_theme
      element_parent.options[:theme]
    end

    private def add_element(element)
      element_parent.add(element)

      element
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

      _container
    end
  end
end
