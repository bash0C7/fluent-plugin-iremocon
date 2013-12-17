require 'iremocon'

module Fluent
  class Fluent::IremoconOutput < Fluent::Output
    Fluent::Plugin.register_output('iremocon', self)

    def initialize
      super
    end

    config_param :host, :string
    config_param :port, :integer, :default => 51013
    config_param :command, :string, :default => 'is'
    config_param :command_value_key, :string
    config_param :interval, :integer, :default => 5
    
    def configure(conf)
      super
      
      @q = Queue.new
    end

    def start
      super

      @thread = Thread.new(&method(:post))
    rescue
      $log.warn "raises exception: #{$!.class}, '#{$!.message}"
    end

    def shutdown
      super

      Thread.kill(@thread)
    end
    
    def emit(tag, es, chain)
      es.each {|time, record|
        @q.push record[@command_value_key] if record.has_key? @command_value_key
      }

      chain.next
    rescue
      $log.warn "raises exception: #{$!.class}, '#{$!.message}'"
    end

    private
    
    def post
      loop do
        begin
          send_command @q.pop
          sleep(@interval)
        rescue
          $log.warn "raises exception: #{$!.class}, '#{$!.message}, #{param}'"
        end
      end
    end

    def send_command command
      #todo: capture_stdout
      remocon = Iremocon.new(@host, @port)
      remocon.send @command, command
      remocon.instance_eval {@telnet.close}
    end    
  end
end
