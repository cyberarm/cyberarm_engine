module CyberarmEngine
  class OpenGLRenderer
    @@immediate_mode_warning = false

    attr_accessor :show_wireframe
    attr_reader :number_of_vertices

    def initialize(width:, height:, show_wireframe: false)
      @width = width
      @height = height
      @show_wireframe = show_wireframe

      @number_of_vertices = 0

      @g_buffer = GBuffer.new(width: @width, height: @height)
    end

    def canvas_size_changed
      @g_buffer.unbind_framebuffer
      @g_buffer.clean_up

      @g_buffer = GBuffer.new(width: @width, height: @height)
    end

    def render(camera, lights, entities)
      @number_of_vertices = 0

      glViewport(0, 0, @width, @height)
      glEnable(GL_DEPTH_TEST)

      if Shader.available?("g_buffer") && Shader.available?("lighting")
        @g_buffer.bind_for_writing
        gl_error?

        glClearColor(0.0, 0.0, 0.0, 0.0)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        Shader.use("g_buffer") do |shader|
          gl_error?

          entities.each do |entity|
            next unless entity.visible && entity.renderable

            shader.uniform_transform("projection", camera.projection_matrix)
            shader.uniform_transform("view", camera.view_matrix)
            shader.uniform_transform("model", entity.model_matrix)
            shader.uniform_vec3("cameraPosition", camera.position)

            gl_error?
            draw_model(entity.model, shader)
            entity.draw

            @number_of_vertices += entity.model.vertices_count
          end
        end

        @g_buffer.unbind_framebuffer
        gl_error?

        @g_buffer.bind_for_reading
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0)

        lighting(lights)
        gl_error?

        post_processing
        gl_error?

        # render_framebuffer
        gl_error?

        @g_buffer.unbind_framebuffer
        gl_error?
      else
        unless @@immediate_mode_warning
          puts "Shaders are disabled or failed to compile, using immediate mode for rendering..."
        end
        @@immediate_mode_warning = true

        gl_error?
        lights.each(&:draw)
        camera.draw

        glEnable(GL_NORMALIZE)
        entities.each do |entity|
          next unless entity.visible && entity.renderable

          glPushMatrix

          glTranslatef(entity.position.x, entity.position.y, entity.position.z)
          glScalef(entity.scale.x, entity.scale.y, entity.scale.z)
          glRotatef(entity.orientation.x, 1.0, 0, 0)
          glRotatef(entity.orientation.y, 0, 1.0, 0)
          glRotatef(entity.orientation.z, 0, 0, 1.0)

          gl_error?
          draw_mesh(entity.model)
          entity.draw
          glPopMatrix

          @number_of_vertices += entity.model.vertices_count
        end
      end

      gl_error?
    end

    def copy_g_buffer_to_screen
      @g_buffer.set_read_buffer(:position)
      glBlitFramebuffer(0, 0, @g_buffer.width, @g_buffer.height,
                        0, 0, @g_buffer.width / 2, @g_buffer.height / 2,
                        GL_COLOR_BUFFER_BIT, GL_LINEAR)

      @g_buffer.set_read_buffer(:diffuse)
      glBlitFramebuffer(0, 0, @g_buffer.width, @g_buffer.height,
                        0, @g_buffer.height / 2, @g_buffer.width / 2, @g_buffer.height,
                        GL_COLOR_BUFFER_BIT, GL_LINEAR)

      @g_buffer.set_read_buffer(:normal)
      glBlitFramebuffer(0, 0, @g_buffer.width, @g_buffer.height,
                        @g_buffer.width / 2, @g_buffer.height / 2, @g_buffer.width, @g_buffer.height,
                        GL_COLOR_BUFFER_BIT, GL_LINEAR)

      @g_buffer.set_read_buffer(:texcoord)
      glBlitFramebuffer(0, 0, @g_buffer.width, @g_buffer.height,
                        @g_buffer.width / 2, 0, @g_buffer.width, @g_buffer.height / 2,
                        GL_COLOR_BUFFER_BIT, GL_LINEAR)
    end

    def lighting(lights)
      Shader.use("lighting") do |shader|
        glBindVertexArray(@g_buffer.screen_vbo)

        glDisable(GL_DEPTH_TEST)
        glEnable(GL_BLEND)

        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, @g_buffer.texture(:diffuse))
        shader.uniform_integer("diffuse", 0)

        glActiveTexture(GL_TEXTURE1)
        glBindTexture(GL_TEXTURE_2D, @g_buffer.texture(:position))
        shader.uniform_integer("position", 1)

        glActiveTexture(GL_TEXTURE2)
        glBindTexture(GL_TEXTURE_2D, @g_buffer.texture(:texcoord))
        shader.uniform_integer("texcoord", 2)

        glActiveTexture(GL_TEXTURE3)
        glBindTexture(GL_TEXTURE_2D, @g_buffer.texture(:normal))
        shader.uniform_integer("normal", 3)

        glActiveTexture(GL_TEXTURE4)
        glBindTexture(GL_TEXTURE_2D, @g_buffer.texture(:depth))
        shader.uniform_integer("depth", 4)

        lights.each_with_index do |light, _i|
          shader.uniform_integer("light[0].type", light.type)
          shader.uniform_vec3("light[0].direction", light.direction)
          shader.uniform_vec3("light[0].position", light.position)
          shader.uniform_vec3("light[0].diffuse", light.diffuse)
          shader.uniform_vec3("light[0].ambient", light.ambient)
          shader.uniform_vec3("light[0].specular", light.specular)

          glDrawArrays(GL_TRIANGLES, 0, @g_buffer.vertices.size)
        end

        glBindVertexArray(0)
      end
    end

    def post_processing
    end

    def render_framebuffer
      if Shader.available?("lighting")
        Shader.use("lighting") do |shader|
          glBindVertexArray(@g_buffer.screen_vbo)

          glDisable(GL_DEPTH_TEST)
          glEnable(GL_BLEND)

          glActiveTexture(GL_TEXTURE0)
          glBindTexture(GL_TEXTURE_2D, @g_buffer.texture(:diffuse))
          shader.uniform_integer("diffuse_texture", 0)

          glDrawArrays(GL_TRIANGLES, 0, @g_buffer.vertices.size)

          glBindVertexArray(0)
        end
      end
    end

    def draw_model(model, shader)
      glBindVertexArray(model.vertex_array_id)
      glEnableVertexAttribArray(0)
      glEnableVertexAttribArray(1)
      glEnableVertexAttribArray(2)
      if model.has_texture?
        glEnableVertexAttribArray(3)
        glEnableVertexAttribArray(4)
      end

      if @show_wireframe
        glLineWidth(2)
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
        Shader.active_shader.uniform_boolean("disableLighting", true)

        glDrawArrays(GL_TRIANGLES, 0, model.faces.count * 3)

        Shader.active_shader.uniform_boolean("disableLighting", false)
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
        glLineWidth(1)
      end

      offset = 0
      model.objects.each do |object|
        shader.uniform_boolean("hasTexture", object.has_texture?)

        if object.has_texture?
          glBindTexture(GL_TEXTURE_2D, object.materials.find { |mat| mat.texture_id }.texture_id)
        else
          glBindTexture(GL_TEXTURE_2D, 0)
        end

        glDrawArrays(GL_TRIANGLES, offset, object.faces.count * 3)
        offset += object.faces.count * 3
      end

      if model.has_texture?
        glDisableVertexAttribArray(4)
        glDisableVertexAttribArray(3)

        glBindTexture(GL_TEXTURE_2D, 0)
      end
      glDisableVertexAttribArray(2)
      glDisableVertexAttribArray(1)
      glDisableVertexAttribArray(0)

      glBindBuffer(GL_ARRAY_BUFFER, 0)
      glBindVertexArray(0)
    end

    def draw_mesh(model)
      model.objects.each_with_index do |o, _i|
        glEnable(GL_COLOR_MATERIAL)
        glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
        glShadeModel(GL_FLAT) unless o.faces.first[4]
        glShadeModel(GL_SMOOTH) if o.faces.first[4]
        glEnableClientState(GL_VERTEX_ARRAY)
        glEnableClientState(GL_COLOR_ARRAY)
        glEnableClientState(GL_NORMAL_ARRAY)

        if o.has_texture?
          glEnable(GL_TEXTURE_2D)
          glBindTexture(GL_TEXTURE_2D, o.materials.find { |mat| mat.texture_id }.texture_id)
          glEnableClientState(GL_TEXTURE_COORD_ARRAY)
          glTexCoordPointer(3, GL_FLOAT, 0, o.flattened_uvs)
        end

        glVertexPointer(4, GL_FLOAT, 0, o.flattened_vertices)
        glColorPointer(3, GL_FLOAT, 0, o.flattened_materials)
        glNormalPointer(GL_FLOAT, 0, o.flattened_normals)

        if @show_wireframe # This is kinda expensive
          glDisable(GL_LIGHTING)
          glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
          glPolygonOffset(2, 0.5)
          glLineWidth(3)

          glDrawArrays(GL_TRIANGLES, 0, o.flattened_vertices_size / 4)

          glLineWidth(1)
          glPolygonOffset(0, 0)
          glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
          glEnable(GL_LIGHTING)

          glDrawArrays(GL_TRIANGLES, 0, o.flattened_vertices_size / 4)
        else
          glDrawArrays(GL_TRIANGLES, 0, o.flattened_vertices_size / 4)
        end

        # glBindBuffer(GL_ARRAY_BUFFER, 0)

        glDisableClientState(GL_VERTEX_ARRAY)
        glDisableClientState(GL_COLOR_ARRAY)
        glDisableClientState(GL_NORMAL_ARRAY)

        if o.has_texture?
          glDisableClientState(GL_TEXTURE_COORD_ARRAY)
          glDisable(GL_TEXTURE_2D)
        end

        glDisable(GL_COLOR_MATERIAL)
      end
    end
  end
end
