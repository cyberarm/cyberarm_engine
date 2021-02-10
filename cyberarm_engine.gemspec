lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cyberarm_engine/version"

Gem::Specification.new do |spec|
  spec.name          = "cyberarm_engine"
  spec.version       = CyberarmEngine::VERSION
  spec.authors       = ["Cyberarm"]
  spec.email         = ["matthewlikesrobots@gmail.com"]

  spec.summary       = "Make games quickly and easily with gosu"
  spec.description   = "Yet another game making framework around gosu"
  spec.homepage      = "https://github.com/cyberarm/cyberarm_engine"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib assets]

  spec.add_dependency "clipboard", "~> 1.3.5"
  spec.add_dependency "excon", "~> 0.78.0"
  spec.add_dependency "gosu", "~> 1.1"
  spec.add_dependency "gosu_more_drawables", "~> 0.3"
  # spec.add_dependency "ffi", :platforms => [:mswin, :mingw] # Required by Clipboard on Windows

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
