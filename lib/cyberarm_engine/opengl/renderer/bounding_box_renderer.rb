module CyberarmEngine
  class BoundingBoxRenderer
    attr_reader :bounding_boxes, :vertex_count

    def initialize
      @bounding_boxes = {}
      @vertex_count = 0
    end

    def render(entities)
      entities.each do |entity|
        create_bounding_box(entity, color = nil)
        draw_bounding_boxes
      end

      (@bounding_boxes.keys - entities.map { |e| e.object_id }).each do |key|
        @bounding_boxes.delete(key)
      end
    end

    def create_bounding_box(entity, color = nil)
      color ||= entity.debug_color
      entity_id = entity.object_id

      if @bounding_boxes[entity_id]
        if @bounding_boxes[entity_id][:color] != color
          @bounding_boxes[entity_id][:colors] = mesh_colors(color).pack("f*")
          @bounding_boxes[entity_id][:color]  = color
          return
        else
          return
        end
      end

      @bounding_boxes[entity_id] = {
        entity: entity,
        color: color,
        objects: []
      }

      box = entity.normalize_bounding_box

      normals  = mesh_normals
      colors   = mesh_colors(color)
      vertices = mesh_vertices(box)

      @vertex_count += vertices.size

      @bounding_boxes[entity_id][:vertices_size] = vertices.size
      @bounding_boxes[entity_id][:vertices]      = vertices.pack("f*")
      @bounding_boxes[entity_id][:normals]       = normals.pack("f*")
      @bounding_boxes[entity_id][:colors]        = colors.pack("f*")

      entity.model.objects.each do |mesh|
        data = {}
        box = mesh.bounding_box.normalize(entity)

        normals  = mesh_normals
        colors   = mesh_colors(mesh.debug_color)
        vertices = mesh_vertices(box)

        @vertex_count += vertices.size

        data[:vertices_size] = vertices.size
        data[:vertices]      = vertices.pack("f*")
        data[:normals]       = normals.pack("f*")
        data[:colors]        = colors.pack("f*")

        @bounding_boxes[entity_id][:objects] << data
      end
    end

    def mesh_normals
      [
        0, 1, 0,
        0, 1, 0,
        0, 1, 0,
        0, 1, 0,
        0, 1, 0,
        0, 1, 0,

        0, -1, 0,
        0, -1, 0,
        0, -1, 0,
        0, -1, 0,
        0, -1, 0,
        0, -1, 0,

        0, 0, 1,
        0, 0, 1,
        0, 0, 1,
        0, 0, 1,
        0, 0, 1,
        0, 0, 1,

        1, 0, 0,
        1, 0, 0,
        1, 0, 0,
        1, 0, 0,
        1, 0, 0,
        1, 0, 0,

        -1, 0, 0,
        -1, 0, 0,
        -1, 0, 0,
        -1, 0, 0,
        -1, 0, 0,
        -1, 0, 0,

        -1, 0, 0,
        -1, 0, 0,
        -1, 0, 0,

        -1, 0, 0,
        -1, 0, 0,
        -1, 0, 0
      ]
    end

    def mesh_colors(color)
      [
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue,
        color.red, color.green, color.blue
      ]
    end

    def mesh_vertices(box)
      [
        box.min.x, box.max.y, box.max.z,
        box.min.x, box.max.y, box.min.z,
        box.max.x, box.max.y, box.min.z,

        box.min.x, box.max.y, box.max.z,
        box.max.x, box.max.y, box.max.z,
        box.max.x, box.max.y, box.min.z,

        box.max.x, box.min.y, box.min.z,
        box.max.x, box.min.y, box.max.z,
        box.min.x, box.min.y, box.max.z,

        box.max.x, box.min.y, box.min.z,
        box.min.x, box.min.y, box.min.z,
        box.min.x, box.min.y, box.max.z,

        box.min.x, box.max.y, box.max.z,
        box.min.x, box.max.y, box.min.z,
        box.min.x, box.min.y, box.min.z,

        box.min.x, box.min.y, box.max.z,
        box.min.x, box.min.y, box.min.z,
        box.min.x, box.max.y, box.max.z,

        box.max.x, box.max.y, box.max.z,
        box.max.x, box.max.y, box.min.z,
        box.max.x, box.min.y, box.min.z,

        box.max.x, box.min.y, box.max.z,
        box.max.x, box.min.y, box.min.z,
        box.max.x, box.max.y, box.max.z,

        box.min.x, box.max.y, box.max.z,
        box.max.x, box.max.y, box.max.z,
        box.max.x, box.min.y, box.max.z,

        box.min.x, box.max.y, box.max.z,
        box.max.x, box.min.y, box.max.z,
        box.min.x, box.min.y, box.max.z,

        box.max.x, box.min.y, box.min.z,
        box.min.x, box.min.y, box.min.z,
        box.min.x, box.max.y, box.min.z,

        box.max.x, box.min.y, box.min.z,
        box.min.x, box.max.y, box.min.z,
        box.max.x, box.max.y, box.min.z
      ]
    end

    def draw_bounding_boxes
      @bounding_boxes.each do |key, bounding_box|
        glPushMatrix

        glTranslatef(
          bounding_box[:entity].position.x,
          bounding_box[:entity].position.y,
          bounding_box[:entity].position.z
        )
        draw_bounding_box(bounding_box)
        @bounding_boxes[key][:objects].each { |o| draw_bounding_box(o) }

        glPopMatrix
      end
    end

    def draw_bounding_box(bounding_box)
      glEnableClientState(GL_VERTEX_ARRAY)
      glEnableClientState(GL_COLOR_ARRAY)
      glEnableClientState(GL_NORMAL_ARRAY)

      glVertexPointer(3, GL_FLOAT, 0, bounding_box[:vertices])
      glColorPointer(3, GL_FLOAT, 0, bounding_box[:colors])
      glNormalPointer(GL_FLOAT, 0, bounding_box[:normals])

      glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
      glDisable(GL_LIGHTING)
      glDrawArrays(GL_TRIANGLES, 0, bounding_box[:vertices_size] / 3)
      glEnable(GL_LIGHTING)
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)

      glDisableClientState(GL_VERTEX_ARRAY)
      glDisableClientState(GL_COLOR_ARRAY)
      glDisableClientState(GL_NORMAL_ARRAY)
    end
  end
end
