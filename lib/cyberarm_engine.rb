begin
  require File.expand_path("../../ffi-gosu/lib/gosu", File.dirname(__FILE__))
rescue LoadError => e
  pp e
  require "gosu"
end

require_relative "cyberarm_engine/version"

require_relative "cyberarm_engine/common"

require_relative "cyberarm_engine/game_object"
require_relative "cyberarm_engine/engine"

require_relative "cyberarm_engine/bounding_box"
require_relative "cyberarm_engine/vector"
require_relative "cyberarm_engine/transform"
require_relative "cyberarm_engine/ray"
require_relative "cyberarm_engine/shader" if defined?(OpenGL)
require_relative "cyberarm_engine/background"

require_relative "cyberarm_engine/text"
require_relative "cyberarm_engine/timer"

require_relative "cyberarm_engine/ui/theme"
require_relative "cyberarm_engine/ui/event"
require_relative "cyberarm_engine/ui/style"
require_relative "cyberarm_engine/ui/border_canvas"
require_relative "cyberarm_engine/ui/element"
require_relative "cyberarm_engine/ui/elements/label"
require_relative "cyberarm_engine/ui/elements/button"
require_relative "cyberarm_engine/ui/elements/toggle_button"
require_relative "cyberarm_engine/ui/elements/edit_line"
require_relative "cyberarm_engine/ui/elements/image"
require_relative "cyberarm_engine/ui/elements/container"
require_relative "cyberarm_engine/ui/elements/flow"
require_relative "cyberarm_engine/ui/elements/stack"
require_relative "cyberarm_engine/ui/elements/check_box"
require_relative "cyberarm_engine/ui/elements/progress"

require_relative "cyberarm_engine/ui/dsl"

require_relative "cyberarm_engine/game_state"
require_relative "cyberarm_engine/ui/gui_state"
