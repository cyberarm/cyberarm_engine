begin
  require "opengl"
rescue LoadError
  puts "Required gem is not installed, please install 'opengl-bindings' and try again."
  exit(1)
end

module CyberarmEngine
  def gl_error?
    e = glGetError
    if e != GL_NO_ERROR
      warn "OpenGL error detected by handler at: #{caller[0]}"
      warn "    #{gluErrorString(e)} (#{e})\n"
      exit if Window.instance&.exit_on_opengl_error?
    end
  end

  def preload_default_shaders
    shaders = %w[g_buffer lighting]
    shaders.each do |shader|
      Shader.new(
        name: shader,
        includes_dir: "#{CYBERARM_ENGINE_ROOT_PATH}/assets/shaders/include",
        vertex: "#{CYBERARM_ENGINE_ROOT_PATH}/assets/shaders/vertex/#{shader}.glsl",
        fragment: "#{CYBERARM_ENGINE_ROOT_PATH}/assets/shaders/fragment/#{shader}.glsl"
      )
    end
  end
end

require_relative "opengl/shader"
require_relative "opengl/texture"
require_relative "opengl/light"
require_relative "opengl/perspective_camera"
require_relative "opengl/orthographic_camera"

require_relative "opengl/renderer/g_buffer"
require_relative "opengl/renderer/bounding_box_renderer"
require_relative "opengl/renderer/opengl_renderer"
require_relative "opengl/renderer/renderer"
