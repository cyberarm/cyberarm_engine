MRuby::Gem::Specification.new("mruby-cyberarm_engine") do |spec|
  spec.license = "MIT"
  spec.authors = "cyberarm"
  spec.summary = " Yet another framework for building games with Gosu"

  lib_rbfiles = []
  # Dir.glob("#{File.expand_path("..", __FILE__)}/lib/**/*.rb").reject do |f|
    # File.basename(f.downcase, ".rb") == "cyberarm_engine" ||
    # File.basename(f.downcase, ".rb") == "opengl" ||
    # f.downcase.include?("/opengl/")
  # end.reverse!

  local_path = File.expand_path("..", __FILE__)
  File.read("#{local_path}/lib/cyberarm_engine.rb").each_line do |line|
    line = line.strip

    next unless line.start_with?("require_relative")

    file = line.split("require_relative").last.strip.gsub("\"", "")

    next if file.include?(" if ")

    lib_rbfiles << "#{local_path}/lib/#{file}.rb"
  end

  pp lib_rbfiles

  spec.rbfiles = lib_rbfiles
end
