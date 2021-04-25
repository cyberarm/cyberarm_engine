module CyberarmEngine
  class PerspectiveCamera
    attr_accessor :position, :orientation, :aspect_ratio, :field_of_view,
                  :min_view_distance, :max_view_distance

    def initialize(position:, aspect_ratio:, orientation: Vector.new(0, 0, 0),
                   field_of_view: 70.0, min_view_distance: 0.1, max_view_distance: 1024.0)
      @position = position
      @orientation = orientation

      @aspect_ratio = aspect_ratio
      @field_of_view = field_of_view

      @min_view_distance = min_view_distance
      @max_view_distance = max_view_distance
    end

    def draw
      glMatrixMode(GL_PROJECTION)
      glLoadIdentity
      gluPerspective(@field_of_view, @aspect_ratio, @min_view_distance, @max_view_distance)
      glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
      glRotatef(@orientation.x, 1, 0, 0)
      glRotatef(@orientation.y, 0, 1, 0)
      glTranslatef(-@position.x, -@position.y, -@position.z)
      glMatrixMode(GL_MODELVIEW)
      glLoadIdentity
    end

    def projection_matrix
      Transform.perspective(@field_of_view, @aspect_ratio, @min_view_distance, @max_view_distance)
    end

    def view_matrix
      Transform.translate_3d(@position * -1) * Transform.rotate_3d(@orientation)
    end
  end
end
