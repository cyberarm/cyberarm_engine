# CyberarmEngine

Yet Another Game Engine On Top Of Gosu

## Features
* [Shoes-like](http://shoesrb.com) GUI support
* OpenGL Shader support (requires [opengl-bindings](https://github.com/vaiorabbit/ruby-opengl) gem)
* Includes classes for handling Vectors, Rays, Bounding Boxes, and Transforms
* GameState system
* Monolithic GameObjects

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cyberarm_engine'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cyberarm_engine

## Usage

```ruby
require "cyberarm_engine"

class Hello < CyberarmEngine::GuiState
  def setup
    stack do
      label "Hello World!"

      button "close" do
        window.close
      end
    end
  end
end

class Window < CyberarmEngine::Engine
  def initialize
    super
    self.show_cursor = true

    push_state(Hello)
  end
end

Window.new.show
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cyberarm/cyberarm_engine.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CyberarmEngine project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the ruby moto of "Matz is nice so we are nice."
