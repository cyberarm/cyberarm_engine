module CyberarmEngine
  # Ref: https://github.com/vaiorabbit/ruby-opengl/blob/master/sample/OrangeBook/brick.rb
  class Shader
    include OpenGL
    @@shaders = {}

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
    def initialize(name:, vertex: "shaders/default.vert", fragment:)
      @name = name
      @vertex_file   = vertex
      @fragment_file = fragment
      @compiled = false

      @program = nil

      @error_buffer_size = 1024
      @variable_missing = {}

      raise ArgumentError, "Shader files not found: #{@vertex_file} or #{@fragment_file}" unless shader_files_exist?

      create_shaders
      compile_shaders

      # Only add shader if it successfully compiles
      if @compiled
        Shader.add(@name, self)
      else
        puts "FAILED to compile shader: #{@name}", ""
      end
    end

    def shader_files_exist?
      File.exist?(@vertex_file) && File.exist?(@fragment_file)
    end

    def create_shaders
      @vertex   = glCreateShader(GL_VERTEX_SHADER)
      @fragment = glCreateShader(GL_FRAGMENT_SHADER)

      source = [File.read(@vertex_file)].pack('p')
      size   = [File.size(@vertex_file)].pack('I')
      glShaderSource(@vertex, 1, source, size)

      source = [File.read(@fragment_file)].pack('p')
      size   = [File.size(@fragment_file)].pack('I')
      glShaderSource(@fragment, 1, source, size)
    end

    def compile_shaders
      return unless shader_files_exist?

      glCompileShader(@vertex)
      buffer = '    '
      glGetShaderiv(@vertex, GL_COMPILE_STATUS, buffer)
      compiled = buffer.unpack('L')[0]

      if compiled == 0
        log = ' ' * @error_buffer_size
        glGetShaderInfoLog(@vertex, @error_buffer_size, nil, log)
        puts "Shader Error: Program \"#{@name}\""
        puts "  Vectex Shader InfoLog:", "  #{log.strip.split("\n").join("\n  ")}\n\n"
        puts "  Shader Compiled status: #{compiled}"
        puts "    NOTE: assignment of uniforms in shaders is illegal!"
        puts
        return
      end

      glCompileShader(@fragment)
      buffer = '    '
      glGetShaderiv(@fragment, GL_COMPILE_STATUS, buffer)
      compiled = buffer.unpack('L')[0]

      if compiled == 0
        log = ' ' * @error_buffer_size
        glGetShaderInfoLog(@fragment, @error_buffer_size, nil, log)
        puts "Shader Error: Program \"#{@name}\""
        puts "  Fragment Shader InfoLog:", "  #{log.strip.split("\n").join("\n  ")}\n\n"
        puts "  Shader Compiled status: #{compiled}"
        puts "    NOTE: assignment of uniforms in shader is illegal!"
        puts
        return
      end

      @program = glCreateProgram
      glAttachShader(@program, @vertex)
      glAttachShader(@program, @fragment)
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

    def set_uniform(variable, value, location = nil)
      attr_loc = location ? location : attribute_location(variable)

      case value.class.to_s.downcase.to_sym
      when :integer
        glUniform1i(attr_loc, value)
      when :float
        glUniform1f(attr_loc, value)
      when :string
      when :array
      else
        raise NotImplementedError, "Shader support for #{value.class.inspect} not implemented."
      end

      Window.handle_gl_error
    end
  end
end