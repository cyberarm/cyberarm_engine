module CyberarmEngine
  # Ref: https://github.com/vaiorabbit/ruby-opengl/blob/master/sample/OrangeBook/brick.rb
  class Shader
    include OpenGL
    @@shaders = {} # Cache for {Shader} instances
    PREPROCESSOR_CHARACTER = "@".freeze # magic character for preprocessor phase of {Shader} compilation

    # add instance of {Shader} to cache
    #
    # @param name [String]
    # @param instance [Shader]
    def self.add(name, instance)
      @@shaders[name] = instance
    end

    # removes {Shader} from cache and cleans up
    #
    # @param name [String]
    def self.delete(name)
      shader = @@shaders.dig(name)

      if shader
        @@shaders.delete(name)

        glDeleteProgram(shader.program) if shader.compiled?
      end
    end

    ##
    # runs _block_ using {Shader} with _name_
    #
    # @example
    #
    #   CyberarmEngine::Shader.use("blur") do |shader|
    #     shader.uniform_float("radius", 20.0)
    #     # OpenGL Code that uses shader
    #   end
    #
    # @param name [String] name of {Shader} to use
    # @return [void]
    def self.use(name, &block)
      shader = @@shaders.dig(name)
      if shader
        shader.use(&block)
      else
        raise ArgumentError, "Shader '#{name}' not found!"
      end
    end

    # returns whether {Shader} with _name_ is in cache
    #
    # @param name [String]
    # @return [Boolean]
    def self.available?(name)
      @@shaders.dig(name).is_a?(Shader)
    end

    # returns instance of {Shader}, if it exists
    #
    # @param name [String]
    # @return [Shader?]
    def self.get(name)
      @@shaders.dig(name)
    end

    # returns currently active {Shader}, if one is active
    #
    # @return [Shader?]
    class << self
      attr_reader :active_shader
    end

    # sets currently active {Shader}
    #
    # @param instance [Shader] instance of {Shader} to set as active
    class << self
      attr_writer :active_shader
    end

    # stops using currently active {Shader}
    def self.stop
      shader = Shader.active_shader

      if shader
        shader.stop
      else
        raise ArgumentError, "No active shader to stop!"
      end
    end

    # returns location of OpenGL Shader uniform
    #
    # @param variable [String]
    def self.attribute_location(variable)
      raise "No active shader!" unless Shader.active_shader

      Shader.active_shader.attribute_location(variable)
    end

    # sets _variable_ to _value_
    #
    # @param variable [String]
    # @param value
    def self.set_uniform(variable, value)
      raise "No active shader!" unless Shader.active_shader

      Shader.active_shader.set_uniform(variable, value)
    end

    attr_reader :name, :program

    def initialize(name:, fragment:, includes_dir: nil, vertex: "shaders/default.vert")
      raise "Shader name can not be blank" if name.length == 0

      @name = name
      @includes_dir = includes_dir
      @compiled = false

      @program = nil

      @error_buffer_size = 1024 * 8
      @variable_missing = {}

      @data = { shaders: {} }

      unless shader_files_exist?(vertex: vertex, fragment: fragment)
        raise ArgumentError, "Shader files not found: #{vertex} or #{fragment}"
      end

      create_shader(type: :vertex, source: File.read(vertex))
      create_shader(type: :fragment, source: File.read(fragment))

      compile_shader(type: :vertex)
      compile_shader(type: :fragment)
      link_shaders

      @data[:shaders].each { |_key, id| glDeleteShader(id) }

      # Only add shader if it successfully compiles
      if @compiled
        puts "compiled!"
        puts "Compiled shader: #{@name}"
        Shader.add(@name, self)
      else
        glDeleteProgram(@program)
        warn "FAILED to compile shader: #{@name}", ""
      end
    end

    # whether vertex and fragment files exist on disk
    #
    # @return [Boolean]
    def shader_files_exist?(vertex:, fragment:)
      File.exist?(vertex) && File.exist?(fragment)
    end

    # creates an OpenGL Shader of _type_ using _source_
    #
    # @param type [Symbol] valid values are: :vertex, :fragment
    # @param source [String] source code for shader
    def create_shader(type:, source:)
      _shader = nil

      case type
      when :vertex
        _shader = glCreateShader(GL_VERTEX_SHADER)
      when :fragment
        _shader = glCreateShader(GL_FRAGMENT_SHADER)
      else
        raise ArgumentError, "Unsupported shader type: #{type.inspect}"
      end

      processed_source = preprocess_source(source: source)

      _source = [processed_source].pack("p")
      _size = [processed_source.length].pack("I")
      glShaderSource(_shader, 1, _source, _size)

      @data[:shaders][type] = _shader
    end

    # evaluates shader preprocessors
    #
    # currently supported preprocessors:
    #
    #   @include "file/path" "another/file/path" # => Replace line with contents of file; Shader includes_dir must be specified in constructor
    #
    # @example
    #   # Example Vertex Shader #
    #   # #version 330 core
    #   # @include "material_struct"
    #   # void main() {
    #   #   gl_Position = vec4(1, 1, 1, 1);
    #   # }
    #
    #   Shader.new(name: "model_renderer", includes_dir: "path/to/includes", vertex: "path/to/vertex_shader.glsl")
    #
    # @param source shader source code
    def preprocess_source(source:)
      lines = source.lines

      lines.each_with_index do |line, i|
        next unless line.start_with?(PREPROCESSOR_CHARACTER)

        preprocessor = line.strip.split(" ")
        lines.delete(line)

        case preprocessor.first
        when "@include"
          unless @includes_dir
            raise ArgumentError,
                  "Shader preprocessor include directory was not given for shader #{@name}"
          end

          preprocessor[1..preprocessor.length - 1].join.scan(/"([^"]*)"/).flatten.each do |file|
            source = File.read("#{@includes_dir}/#{file}.glsl")

            lines.insert(i, source)
          end
        else
          warn "Unsupported preprocessor #{preprocessor.first} for #{@name}"
        end
      end

      lines.join
    end

    # compile OpenGL Shader of _type_
    #
    # @return [Boolean] whether compilation succeeded
    def compile_shader(type:)
      _compiled = false
      _shader = @data[:shaders][type]
      raise ArgumentError, "No shader for #{type.inspect}" unless _shader

      glCompileShader(_shader)
      buffer = "    "
      glGetShaderiv(_shader, GL_COMPILE_STATUS, buffer)
      compiled = buffer.unpack1("L")

      if compiled == 0
        log = " " * @error_buffer_size
        glGetShaderInfoLog(_shader, @error_buffer_size, nil, log)
        puts "Shader Error: Program \"#{@name}\""
        puts "  #{type.to_s.capitalize} Shader InfoLog:", "  #{log.strip.split("\n").join("\n  ")}\n\n"
        puts "  Shader Compiled status: #{compiled}"
        puts "    NOTE: assignment of uniforms in shaders is illegal!"
        puts
      else
        _compiled = true
      end

      _compiled
    end

    # link compiled OpenGL Shaders in to a OpenGL Program
    #
    # @note linking must succeed or shader cannot be used
    #
    # @return [Boolean] whether linking succeeded
    def link_shaders
      @program = glCreateProgram
      @data[:shaders].values.each do |_shader|
        glAttachShader(@program, _shader)
      end
      glLinkProgram(@program)

      buffer = "    "
      glGetProgramiv(@program, GL_LINK_STATUS, buffer)
      linked = buffer.unpack1("L")

      if linked == 0
        log = " " * @error_buffer_size
        glGetProgramInfoLog(@program, @error_buffer_size, nil, log)
        puts "Shader Error: Program \"#{@name}\""
        puts "  Program InfoLog:", "  #{log.strip.split("\n").join("\n  ")}\n\n"
      end

      @compiled = !(linked == 0)
    end

    # Returns the location of a uniform _variable_
    #
    # @param variable [String]
    # @return [Integer] location of uniform
    def variable(variable)
      loc = glGetUniformLocation(@program, variable)
      if loc == -1
        unless @variable_missing[variable]
          puts "Shader Error: Program \"#{@name}\" has no such uniform named \"#{variable}\"",
               "  Is it used in the shader? GLSL may have optimized it out.", "  Is it miss spelled?"
        end
        @variable_missing[variable] = true
      end
      loc
    end

    # @see Shader.use Shader.use
    def use(&block)
      return unless compiled?
      raise "Another shader is already in use! #{Shader.active_shader.name.inspect}" if Shader.active_shader

      Shader.active_shader = self

      glUseProgram(@program)

      if block
        block.call(self)
        stop
      end
    end

    # stop using shader, if shader is active
    def stop
      Shader.active_shader = nil if Shader.active_shader == self
      glUseProgram(0)
    end

    # @return [Boolean] whether {Shader} successfully compiled
    def compiled?
      @compiled
    end

    # returns location of a uniform _variable_
    #
    # @note Use {#variable} for friendly error handling
    # @see #variable Shader#variable
    #
    # @param variable [String]
    # @return [Integer]
    def attribute_location(variable)
      glGetUniformLocation(@program, variable)
    end

    # send {Transform} to {Shader}
    #
    # @param variable [String]
    # @param value [Transform]
    # @param location [Integer]
    # @return [void]
    def uniform_transform(variable, value, location = nil)
      attr_loc = location || attribute_location(variable)

      glUniformMatrix4fv(attr_loc, 1, GL_FALSE, value.to_gl.pack("F16"))
    end

    # send Boolean to {Shader}
    #
    # @param variable [String]
    # @param value [Boolean]
    # @param location [Integer]
    # @return [void]
    def uniform_boolean(variable, value, location = nil)
      attr_loc = location || attribute_location(variable)

      glUniform1i(attr_loc, value ? 1 : 0)
    end

    # send Integer to {Shader}
    # @param variable [String]
    # @param value [Integer]
    # @param location [Integer]
    # @return [void]
    def uniform_integer(variable, value, location = nil)
      attr_loc = location || attribute_location(variable)

      glUniform1i(attr_loc, value)
    end

    # send Float to {Shader}
    #
    # @param variable [String]
    # @param value [Float]
    # @param location [Integer]
    # @return [void]
    def uniform_float(variable, value, location = nil)
      attr_loc = location || attribute_location(variable)

      glUniform1f(attr_loc, value)
    end

    # send {Vector} (x, y, z) to {Shader}
    #
    # @param variable [String]
    # @param value [Vector]
    # @param location [Integer]
    # @return [void]
    def uniform_vec3(variable, value, location = nil)
      attr_loc = location || attribute_location(variable)

      glUniform3f(attr_loc, *value.to_a[0..2])
    end

    # send {Vector} to {Shader}
    #
    # @param variable [String]
    # @param value [Vector]
    # @param location [Integer]
    # @return [void]
    def uniform_vec4(variable, value, location = nil)
      attr_loc = location || attribute_location(variable)

      glUniform4f(attr_loc, *value.to_a)
    end
  end
end
