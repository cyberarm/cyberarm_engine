CYBERARM_ENGINE_ROOT_PATH = File.expand_path("..", __dir__)

if ARGV.join.include?("--ffi-gosu")
  require File.expand_path("../../ffi-gosu/lib/gosu", __dir__)
else
  require "gosu"
end
require "json"

require_relative "cyberarm_engine/version"
require_relative "cyberarm_engine/stats"

require_relative "cyberarm_engine/common"

require_relative "cyberarm_engine/gosu_ext/draw_arc"
require_relative "cyberarm_engine/gosu_ext/draw_circle"
require_relative "cyberarm_engine/gosu_ext/draw_path"

require_relative "cyberarm_engine/notification"
require_relative "cyberarm_engine/notification_manager"

require_relative "cyberarm_engine/game_object"
require_relative "cyberarm_engine/window"

require_relative "cyberarm_engine/bounding_box"
require_relative "cyberarm_engine/vector"
require_relative "cyberarm_engine/transform"
require_relative "cyberarm_engine/ray"
require_relative "cyberarm_engine/background"
require_relative "cyberarm_engine/background_nine_slice"
require_relative "cyberarm_engine/background_image"
require_relative "cyberarm_engine/animator"

require_relative "cyberarm_engine/text"
require_relative "cyberarm_engine/timer"
require_relative "cyberarm_engine/config_file"

require_relative "cyberarm_engine/console"
require_relative "cyberarm_engine/console/command"
require_relative "cyberarm_engine/console/subcommand"
require_relative "cyberarm_engine/console/commands/help_command"

require_relative "cyberarm_engine/ui/dsl"

require_relative "cyberarm_engine/ui/theme"
require_relative "cyberarm_engine/ui/event"
require_relative "cyberarm_engine/ui/style"
require_relative "cyberarm_engine/ui/border_canvas"
require_relative "cyberarm_engine/ui/element"
require_relative "cyberarm_engine/ui/elements/text_block"
require_relative "cyberarm_engine/ui/elements/button"
require_relative "cyberarm_engine/ui/elements/toggle_button"
require_relative "cyberarm_engine/ui/elements/list_box"
require_relative "cyberarm_engine/ui/elements/edit_line"
require_relative "cyberarm_engine/ui/elements/edit_box"
require_relative "cyberarm_engine/ui/elements/image"
require_relative "cyberarm_engine/ui/elements/container"
require_relative "cyberarm_engine/ui/elements/flow"
require_relative "cyberarm_engine/ui/elements/stack"
require_relative "cyberarm_engine/ui/elements/check_box"
require_relative "cyberarm_engine/ui/elements/radio"
require_relative "cyberarm_engine/ui/elements/progress"
require_relative "cyberarm_engine/ui/elements/slider"
require_relative "cyberarm_engine/ui/elements/menu"
require_relative "cyberarm_engine/ui/elements/menu_item"

require_relative "cyberarm_engine/game_state"
require_relative "cyberarm_engine/ui/gui_state"

require_relative "cyberarm_engine/builtin/intro_state"
