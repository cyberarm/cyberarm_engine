module CyberarmEngine
  module DSL
    def flow(options = {}, &block)
      puts "Flow"
      options[:parent] = self
      _flow = Flow.new(options, block)

      @active_container = _flow
      @game_objects << _flow

      return _flow
    end

    def stack(options = {}, &block)
      puts "Stack"
      options[:parent] = self
      _stack = Stack.new(options, block)

      @active_container = _stack
      @game_objects << _stack

      return _stack
    end

    def label(text, options = {})
      options[:parent] = @active_container
      _text = Label.new(text, options)
      @active_container.elements << _text

      return _text
    end

    def button(text, options = {}, &block)
      options[:parent] = @active_container
      _button = Button.new(text, options, block) { if block.is_a?(Proc); block.call; end }
      @active_container.elements << _button

      return _button
    end

    def edit_line(text, options = {}, &block)
      options[:parent] = @active_container
      _edit_line = EditLine.new(text, options, block)
      @active_container.elements << _edit_line

      return _edit_line
    end

    def check_box(options = {}, &block)
      options[:parent] = @active_container
      _check_box = CheckBox.new(options, block)
      @active_container.elements << _check_box

      return _check_box
    end

    def background(color = Gosu::Color::NONE)
      @active_container.background_color = color
    end
  end
end