module CyberarmEngine
  class Texture
    DEFAULT_TEXTURE = "#{CYBERARM_ENGINE_ROOT_PATH}/assets/textures/default.png".freeze

    CACHE = {}

    def self.release_textures
      CACHE.values.each do |id|
        glDeleteTextures(id)
      end
    end

    def self.from_cache(path, retro)
      CACHE.dig("#{path}?retro=#{retro}")
    end

    attr_reader :id

    def initialize(path: nil, image: nil, retro: false)
      raise "keyword :path or :image must be provided!" if path.nil? && image.nil?

      @retro = retro
      @path = path

      if @path
        unless File.exist?(@path)
          warn "Missing texture at: #{@path}"
          @retro = true # override retro setting
          @path = DEFAULT_TEXTURE
        end

        if texture = Texture.from_cache(@path, @retro)
          @id = texture.id
          return
        end

        image = load_image(@path)
        @id = create_from_image(image)
      else
        @id = create_from_image(image)
      end
    end

    def load_image(path)
      CACHE["#{path}?retro=#{@retro}"] = self
      Gosu::Image.new(path, retro: @retro)
    end

    def create_from_image(image)
      array_of_pixels = image.to_blob

      tex_names_buf = " " * 4
      glGenTextures(1, tex_names_buf)
      texture_id = tex_names_buf.unpack1("L2")

      glBindTexture(GL_TEXTURE_2D, texture_id)
      glTexImage2D(GL_TEXTURE_2D, 0, GL_SRGB_ALPHA, image.width, image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, array_of_pixels)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST) if @retro
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR) unless @retro
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
      glGenerateMipmap(GL_TEXTURE_2D)
      gl_error?

      texture_id
    end
  end
end
