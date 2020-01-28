module CyberarmEngine
  # Ref: https://github.com/vaiorabbit/ruby-opengl/blob/master/sample/OrangeBook/brick.rb
  class Shader
    include OpenGL
    @@shaders = {}
    PREPROCESSOR_CHARACTER = "@"

    def self.add(name, instance)
      @@shaders[name] = instance
    end

    def self.use(name, &block)
      shader = @@shaders.dig(name)
      if shader
        shader.use(&block)
      else
        raise ArgumentError, "Shader '#{name}' not found!"
      end
    end

    def self.available?(name)
      @@shaders.dig(name).is_a?(Shader)
    end

    def self.get(name)
      @@shaders.dig(name)
    end

    def self.active_shader
      @active_shader
    end

    def self.active_shader=(instance)
      @active_shader = instance
    end

    def self.stop
      shader = Shader.active_shader

      if shader
        shader.stop
      else
        raise ArgumentError, "No active shader to stop!"
      end
    end

    def self.attribute_location(variable)
      raise RuntimeError, "No active shader!" unless Shader.active_shader
      Shader.active_shader.attribute_location(variable)
    end

    def self.set_uniform(variable, value)
      raise RuntimeError, "No active shader!" unless Shader.active_shader
      Shader.active_shader.set_uniform(variable, value)
    end

    attr_reader :name, :program
    def initialize(name:, includes_dir: nil, vertex: "shaders/default.vert", fragment:)
      raise "Shader name can not be blank" if name.length == 0

      @name = name
      @includes_dir = includes_dir
      @compiled = false

      @program = nil

      @error_buffer_size = 1024
      @variable_missing = {}

      @data = {shaders: {}}

      unless shader_files_exist?(vertex: vertex, fragment: fragment)
        raise ArgumentError, "Shader files not found: #{vertex} or #{fragment}"
      end

      create_shader(type: :vertex, source: File.read(vertex))
      create_shader(type: :fragment, source: File.read(fragment))

      compile_shader(type: :vertex)
      compile_shader(type: :fragment)
      link_shaders

      # Only add shader if it successfully compiles
      if @compiled
        puts "compiled!"
        puts "Compiled shader: #{@name}"
        Shader.add(@name, self)
      else
        warn "FAILED to compile shader: #{@name}", ""
      end
    end

    def shader_files_exist?(vertex:, fragment:)
      File.exist?(vertex) && File.exist?(fragment)
    end

    def create_shader(type:, source:)
      _shader = nil

      case type
      when :vertex
        _shader = glCreateShader(GL_VERTEX_SHADER)
      when :fragment
        _shader = glCreateShader(GL_FRAGMENT_SHADER)
      else
        warn "Unsupported shader type: #{type.inspect}"
      end

      processed_source = preprocess_source(source: source)

      _source = [processed_source].pack("p")
      _size = [processed_source.length].pack("I")
      glShaderSource(_shader, 1, _source, _size)

      @data[:shaders][type] =_shader
    end

    def preprocess_source(source:)
      lines = source.lines

      lines.each_with_index do |line, i|
        if line.start_with?(PREPROCESSOR_CHARACTER)
          preprocessor = line.strip.split(" ")
          lines.delete(line)

          case preprocessor.first
          when "@include"
            raise ArgumentError, "Shader preprocessor include directory was not given for shader #{@name}" unless @includes_dir

            preprocessor[1..preprocessor.length - 1].join.scan(/"([^"]*)"/).flatten.each do |file|
              source = File.read("#{@includes_dir}/#{file}.glsl")

              lines.insert(i, source)
            end
          else
            warn "Unsupported preprocessor #{preprocessor.first} for #{@name}"
          end
        end
      end

      lines.join
    end

    def compile_shader(type:)
      _compiled = false
      _shader = @data[:shaders][type]
      raise ArgumentError, "No shader for #{type.inspect}" unless _shader

      glCompileShader(_shader)
      buffer = '    '
      glGetShaderiv(_shader, GL_COMPILE_STATUS, buffer)
      compiled = buffer.unpack('L')[0]

      if compiled == 0
        log = ' ' * @error_buffer_size
        glGetShaderInfoLog(_shader, @error_buffer_size, nil, log)
        puts "Shader Error: Program \"#{@name}\""
        puts "  #{type.to_s.capitalize} Shader InfoLog:", "  #{log.strip.split("\n").join("\n  ")}\n\n"
        puts "  Shader Compiled status: #{compiled}"
        puts "    NOTE: assignment of uniforms in shaders is illegal!"
        puts
      else
        _compiled = true
      end

      return _compiled
    end

    def link_shaders
      @program = glCreateProgram
      @data[:shaders].values.each do |_shader|
        glAttachShader(@program, _shader)
      end
      glLinkProgram(@program)

      buffer = '    '
      glGetProgramiv(@program, GL_LINK_STATUS, buffer)
      linked = buffer.unpack('L')[0]

      if linked == 0
        log = ' ' * @error_buffer_size
        glGetProgramInfoLog(@program, @error_buffer_size, nil, log)
        puts "Shader Error: Program \"#{@name}\""
        puts "  Program InfoLog:", "  #{log.strip.split("\n").join("\n  ")}\n\n"
      end

      @compiled = linked == 0 ? false : true
    end

    # Returns the location of a uniform variable
    def variable(variable)
      loc = glGetUniformLocation(@program, variable)
      if (loc == -1)
        puts "Shader Error: Program \"#{@name}\" has no such uniform named \"#{variable}\"", "  Is it used in the shader? GLSL may have optimized it out.", "  Is it miss spelled?" unless @variable_missing[variable]
        @variable_missing[variable] = true
      end
      return loc
    end

    def use(&block)
      return unless compiled?
      raise "Another shader is already in use! #{Shader.active_shader.name.inspect}" if Shader.active_shader
      Shader.active_shader=self

      glUseProgram(@program)

      if block
        block.call(self)
        stop
      end
    end

    def stop
      Shader.active_shader = nil if Shader.active_shader == self
      glUseProgram(0)
    end

    def compiled?
      @compiled
    end

    def attribute_location(variable)
      glGetUniformLocation(@program, variable)
    end

    def uniform_transform(variable, value, location = nil)
      attr_loc = location ? location : attribute_location(variable)

      glUniformMatrix4fv(attr_loc, 1, GL_FALSE, value.to_gl.pack("F16"))
    end

    def uniform_boolean(variable, value, location = nil)
      attr_loc = location ? location : attribute_location(variable)

      glUniform1i(attr_loc, value ? 1 : 0)
    end

    def uniform_integer(variable, value, location = nil)
      attr_loc = location ? location : attribute_location(variable)

      glUniform1i(attr_loc, value)
    end

    def uniform_float(variable, value, location = nil)
      attr_loc = location ? location : attribute_location(variable)

      glUniform1f(attr_loc, value)
    end

    def uniform_vec3(variable, value, location = nil)
      attr_loc = location ? location : attribute_location(variable)

      glUniform3f(attr_loc, *value.to_a[0..2])
    end

    def uniform_vec4(variable, value, location = nil)
      attr_loc = location ? location : attribute_location(variable)

      glUniform4f(attr_loc, *value.to_a)
    end
  end
end
