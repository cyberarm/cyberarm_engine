# frozen_string_literal: true

module CyberarmEngine
  class Console
    class Command
      class SubCommand
        def initialize(parent, command, type)
          @parent = parent
          @command = command
          @type = type
        end

        attr_reader :command

        def handle(arguments, console)
          if arguments.size > 1
            console.stdin("to many arguments for #{Style.highlight(command.to_s)}, got #{Style.error(arguments.size)} expected #{Style.notice(1)}.")
            return
          end

          case @type
          when :boolean
            case arguments.last
            when "", nil
              var = @parent.get(command.to_sym) || false
              console.stdin("#{command}: #{Style.highlight(var)}")
            when "on"
              var = @parent.set(command.to_sym, true)
              console.stdin("#{command} => #{Style.highlight(var)}")
            when "off"
              var = @parent.set(command.to_sym, false)
              console.stdin("#{command} => #{Style.highlight(var)}")
            else
              console.stdin("Invalid argument for #{Style.highlight(command.to_s)}, got #{Style.error(arguments.last)} expected #{Style.notice('on')}, or #{Style.notice('off')}.")
            end
          when :string
            case arguments.last
            when "", nil
              var = @parent.get(command.to_sym) || "\"\""
              console.stdin("#{command}: #{Style.highlight(var)}")
            else
              var = @parent.set(command.to_sym, arguments.last)
              console.stdin("#{command} => #{Style.highlight(var)}")
            end
          when :integer
            case arguments.last
            when "", nil
              var = @parent.get(command.to_sym) || "nil"
              console.stdin("#{command}: #{Style.highlight(var)}")
            else
              begin
                var = @parent.set(command.to_sym, Integer(arguments.last))
                console.stdin("#{command} => #{Style.highlight(var)}")
              rescue ArgumentError
                console.stdin("Error: #{Style.error("Expected an integer, got '#{arguments.last}'")}")
              end
            end
          when :decimal
            case arguments.last
            when "", nil
              var = @parent.get(command.to_sym) || "nil"
              console.stdin("#{command}: #{Style.highlight(var)}")
            else
              begin
                var = @parent.set(command.to_sym, Float(arguments.last))
                console.stdin("#{command} => #{Style.highlight(var)}")
              rescue ArgumentError
                console.stdin("Error: #{Style.error("Expected a decimal or integer, got '#{arguments.last}'")}")
              end
            end
          else
            raise RuntimeError
          end
        end

        def values
          case @type
          when :boolean
            %w[on off]
          else
            []
          end
        end

        def usage
          case @type
          when :boolean
            "#{Style.highlight(command)} #{Style.notice('[on|off]')}"
          when :string
            "#{Style.highlight(command)} #{Style.notice('[string]')}"
          when :integer
            "#{Style.highlight(command)} #{Style.notice('[0]')}"
          when :decimal
            "#{Style.highlight(command)} #{Style.notice('[0.0]')}"
          end
        end
      end
    end
  end
end