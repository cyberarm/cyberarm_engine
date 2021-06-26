# frozen_string_literal: true

module CyberarmEngine
  class Console
    class HelpCommand < CyberarmEngine::Console::Command
      def group
        :global
      end

      def command
        :help
      end

      def handle(arguments, console)
        console.stdin(usage(arguments.first))
      end

      def autocomplete(console)
        split = console.text_input.text.split(" ")
        if !console.text_input.text.start_with?(" ") && split.size == 2
          list = console.abbrev_search(Command.list_commands.map { |cmd| cmd.command.to_s }, split.last)
          if list.size == 1
            console.text_input.text = "#{split.first} #{list.first} "
          elsif list.size > 1
            console.stdin(list.map { |cmd| Style.highlight(cmd) }.join(", "))
          end
        end
      end

      def usage(command = nil)
        if command
          if cmd = Command.find(command)
            cmd.usage
          else
            "#{Style.error(command)} is not a command"
          end
        else
          "Available commands:\n#{Command.list_commands.map { |cmd| Style.highlight(cmd.command).to_s }.join(', ')}"
        end
      end
    end
  end
end
