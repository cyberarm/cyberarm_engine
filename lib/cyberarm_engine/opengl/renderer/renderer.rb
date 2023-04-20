module CyberarmEngine
  class Renderer
    attr_reader :opengl_renderer, :bounding_box_renderer

    def initialize
      @bounding_box_renderer = BoundingBoxRenderer.new
      @opengl_renderer = OpenGLRenderer.new(width: CyberarmEngine::Window.instance.width, height: CyberarmEngine::Window.instance.height)
    end

    def draw(camera, lights, entities)
      Stats.frame.start_timing(:opengl_renderer)

      Stats.frame.start_timing(:opengl_model_renderer)
      @opengl_renderer.render(camera, lights, entities)
      Stats.frame.end_timing(:opengl_model_renderer)

      if @show_bounding_boxes
        Stats.frame.start_timing(:opengl_boundingbox_renderer)
        @bounding_box_renderer.render(entities)
        Stats.frame.end_timing(:opengl_boundingbox_renderer)
      end

      Stats.frame.end_timing(:opengl_renderer)
    end

    def canvas_size_changed
      @opengl_renderer.canvas_size_changed
    end

    def finalize # cleanup
    end
  end
end
