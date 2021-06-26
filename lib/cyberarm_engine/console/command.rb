# frozen_string_literal: true

module CyberarmEngine
  class Console
    module Style
      def self.error(string)
        "<c=ff5555>#{string}</c>"
      end

      def self.warn(string)
        "<c=ff7700>#{string}</c>"
      end

      def self.notice(string)
        "<c=55ff55>#{string}</c>"
      end

      def self.highlight(string, color = "5555ff")
        "<c=#{color}>#{string}</c>"
      end
    end

    class Command
      def self.inherited(subclass)
        @list ||= []
        @commands ||= []
        @list << subclass
      end

      def self.setup
        @list ||= []
        @commands = []
        @list.each do |subclass|
          cmd = subclass.new
          if @commands.detect { |c| c.command == cmd.command }
            raise "Command '#{cmd.command}' from '#{cmd.class}' already exists!"
          end

          @commands << cmd
        end
      end

      def self.use(command, arguments, console)
        found_command = @commands.detect { |cmd| cmd.command == command.to_sym }

        if found_command
          found_command.handle(arguments, console)
        else
          console.stdin("Command #{Style.error(command)} not found.")
        end
      end

      def self.find(command)
        @commands.detect { |cmd| cmd.command == command.to_sym }
      end

      def self.list_commands
        @commands
      end

      def initialize
        @store = {}
        @subcommands = []

        setup
      end

      def setup
      end

      def subcommand(command, type)
        if @subcommands.detect { |subcmd| subcmd.command == command.to_sym }
          raise "Subcommand '#{command}' for '#{self.command}' already exists!"
        end

        @subcommands << SubCommand.new(self, command, type)
      end

      def get(key)
        @store[key]
      end

      def set(key, value)
        @store[key] = value
      end

      def group
        raise NotImplementedError
      end

      def command
        raise NotImplementedError
      end

      def handle(arguments, console)
        raise NotImplementedError
      end

      def autocomplete(console)
        split = console.text_input.text.split(" ")

        if @subcommands.size.positive?
          if !console.text_input.text.end_with?(" ") && split.size == 2
            list = console.abbrev_search(@subcommands.map { |cmd| cmd.command.to_s }, split.last)

            if list.size == 1
              console.text_input.text = "#{split.first} #{list.first} "
            else
              return unless list.size.positive?

              console.stdin(list.map { |cmd| Console::Style.highlight(cmd) }.join(", ").to_s)
            end

          # List available options on subcommand
          elsif (console.text_input.text.end_with?(" ") && split.size == 2) || !console.text_input.text.end_with?(" ") && split.size == 3
            subcommand = @subcommands.detect { |cmd| cmd.command.to_s == (split[1]) }

            if subcommand
              if split.size == 2
                console.stdin("Available options: #{subcommand.values.map { |value| Console::Style.highlight(value) }.join(',')}")
              else
                list = console.abbrev_search(subcommand.values, split.last)
                if list.size == 1
                  console.text_input.text = "#{split.first} #{split[1]} #{list.first} "
                elsif list.size.positive?
                  console.stdin("Available options: #{list.map { |value| Console::Style.highlight(value) }.join(',')}")
                end
              end
            end

          # List available subcommands if command was entered and has only a space after it
          elsif console.text_input.text.end_with?(" ") && split.size == 1
            console.stdin("Available subcommands: #{@subcommands.map { |cmd| Console::Style.highlight(cmd.command) }.join(', ')}")
          end
        end
      end

      def handle_subcommand(arguments, console)
        if arguments.size.zero?
          console.stdin(usage)
          return
        end
        subcommand = arguments.delete_at(0)

        found_command = @subcommands.detect { |cmd| cmd.command == subcommand.to_sym }
        if found_command
          found_command.handle(arguments, console)
        else
          console.stdin("Unknown subcommand #{Style.error(subcommand)} for #{Style.highlight(command)}")
        end
      end

      def usage
        raise NotImplementedError
      end
    end
  end
end