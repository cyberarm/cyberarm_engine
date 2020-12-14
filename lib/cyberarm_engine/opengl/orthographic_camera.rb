module CyberarmEngine
  class OrthographicCamera
    attr_accessor :position, :orientation, :zoom, :left, :right, :bottom, :top,
                  :min_view_distance, :max_view_distance

    def initialize(
      position:, right:, top:, orientation: Vector.new(0, 0, 0),
      zoom: 1, left: 0, bottom: 0,
      min_view_distance: 0.1, max_view_distance: 200.0
    )
      @position = position
      @orientation = orientation

      @zoom = zoom

      @left = left
      @right = right
      @bottom = bottom
      @top = top

      @min_view_distance = min_view_distance
      @max_view_distance = max_view_distance
    end

    # Immediate mode renderering fallback
    def draw
      glMatrixMode(GL_PROJECTION)
      glLoadIdentity
      glOrtho(@left, @right, @bottom, @top, @min_view_distance, @max_view_distance)
      glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
      glRotatef(@orientation.x, 1, 0, 0)
      glRotatef(@orientation.y, 0, 1, 0)
      glTranslatef(-@position.x, -@position.y, -@position.z)
      glMatrixMode(GL_MODELVIEW)
      glLoadIdentity
    end

    def projection_matrix
      Transform.orthographic(@left, @right, @bottom, @top, @min_view_distance, @max_view_distance)
    end

    def view_matrix
      Transform.translate_3d(@position * -1) * Transform.rotate_3d(@orientation)
    end
  end
end
