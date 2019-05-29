require "colorize"

module Wrapi
  # Wrapi Logger
  #
  # The Wrapi Logger controls all of the logging within the Wrapi
  # framework. It is based off of some nodejs loggers such as
  # [winston](https://www.npmjs.com/package/winston#logging-levels).
  #
  # ### Level
  #
  # There are six log levels to choose from. Each, by default, will
  # be logged to the console in a different color so that they
  # are easy to tell apart. The levels are:
  #
  # - ERROR   - value: 0; color: red
  # - WARN    - value: 1; color: yellow
  # - INFO    - value: 2; color: blue
  # - VERBOSE - value: 3; color: default (underlined)
  # - DEBUG   - value: 4; color: orange
  # - SILLY   - value: 5; color: rainbow
  #
  # ### Transport
  #
  # Like the winston nodejs library, the Wrapi Logger uses transports
  # as a means of sending your message where it belongs. Provided by
  # default is the `Logger::ConsoleTransport` which outputs messages
  # to STDOUT and STDERR, but you could easily create your own
  # transports for logging to files, sending logs to external
  # services, etc.
  #
  # All transports have to define a log method, which is called
  # every time `Logger#log` is called.
  #
  # ```
  # class MySimpleTransport < Wapi::Logger::Transport
  #   def log(message, level)
  #     puts message
  #   end
  # end
  # ```
  #
  # You can register your logger in the `Logger` constructor or
  # by pushing it to `Logger#transports`.
  #
  # ```
  # logger.transports << MySimpleTransport.new
  # ```
  class Logger
    enum LogLevel
      ERROR
      WARN
      INFO
      VERBOSE
      DEBUG
      SILLY
    end

    {% for level in LogLevel.constants %}
      # Shortcut to `LogLevel::{{level.id}}`
      {{level.id}} = LogLevel::{{level.id}}
    {% end %}

    getter level : Logger::LogLevel
    property transports : Array(Transport) = [] of Transport

    def initialize(
      level : Logger::LogLevel? = nil,
      transports : Array(Transport)? = nil
    )
      @level = level.nil? ? WARN : level

      if transports.nil?
        @transports << ConsoleTransport.new(level: @level)
      else
        @transports = transports
      end
    end

    {% for level in LogLevel.constants %}
      # Logs the `message` if the set `LogLevel` is less than or
      # equal to `:{{level.id}}`
      def {{level.id.downcase}}(message)
        log(message, {{level.id}})
      end
    {% end %}

    # Logs a message at a given level through each transport
    # defined in `#transports`.
    def log(message, level)
      @transports.each do |transport|
        transport.log(message, level)
      end
    end

    abstract class Transport
      abstract def log(message : String, level : Logger::LogLevel)
    end

    # `Transport` for logging messages to STDOUT and STDERR
    class ConsoleTransport < Transport
      DEFAULT_FORMAT = "[%level%] %timestamp% - %message%"

      property format : String

      property color : Bool

      def initialize(@level : Logger::LogLevel, @format = DEFAULT_FORMAT, @color = true)
      end

      def log(message, level)
        return unless level <= @level
        message = format_message(@format, message, level)
        message = color_message(message, level) if @color

        if level == ERROR || level == WARN
          STDERR << message << "\r\n"
        else
          STDOUT << message << "\r\n"
        end
      end

      private def color_message(message, level)
        case level
        when ERROR
          message.colorize(:red)
        when WARN
          message.colorize(:yellow)
        when INFO
          message.colorize(:light_blue)
        when VERBOSE
          message.colorize.mode(:underline)
        when DEBUG
          message.colorize(:orange)
        when SILLY
          colors = [:light_red, :light_green, :light_yellow, :light_blue, :light_magenta, :light_cyan]
          colorized = [] of String
          message.chars.in_groups_of(6) do |block|
            block.each_with_index do |c, i|
              if char = c
                color = colors[i]
                colorized << char.colorize(color).to_s
              end
            end
          end
          message = colorized.join("")
        end
      end

      private def format_message(format, message, level)
        formatters = {
          "name"            => "test app",
          "upcased_name"    => "test app".upcase, # Wrapi::Config.name.upcase
          "timestamp"       => Time.now.to_s("%F %T"),
          "level"           => level.to_s,
          "downcased_level" => level.to_s.downcase,
          "message"         => message,
        }

        output = format

        formatters.each do |name, formatter|
          if formatter.is_a?(Proc)
            formatter = formatter.call(message, level)
          end

          output = output.gsub("%#{name}%", formatter)
        end

        output
      end
    end
  end
end
