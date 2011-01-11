require File.join(File.dirname(__FILE__),'..','clashcommandmapper.rb')

module Clash
  class Application

    COMMANDS = [
      "Connect-VIServer","Get-VM"
    ].sort

    HELP = %Q{Usage:


help - displays this document
exit - (see quit)
quit - quits cloud-administration-shell

Available commands:

#{Clash::Application::COMMANDS.join ", "}

    }

    def initialize options
      @clashcommandmapper = ClashCommandMapper.new options
    end

    def run

      setup_autocompletion
      @subcommand = []
      
      loop do
        begin
          command = Readline.readline "clash > ", true
          command = command.chomp.split " "
          
          if command.index(">")!=nil then
            @subcommand<<command.slice!(0,command.index(">"))
            command.slice!(0)
            command<<(/\n/)
            @subcommand<<command
          else
            @subcommand<<command
          end

          if @subcommand[0]==nil then break end

          while @subcommand[0]!=nil do
            command=@subcommand.slice!(0)
          
            unless command[0].nil?

              if ["quit", "exit"].include?(command[0])
                @subcommand[0]=nil
                return
 
              elsif command[0] == "help"
                puts Clash::Application::HELP
            		
              elsif command[0] == "Connect-VIServer"
                if command.length<4 then 
                  puts "Requires: Server Username Password  Optional: Protocol Port"
                  puts "Example: clash > Connect-VIServer 127.0.0.1 administrator password https 443"
                elsif command.length>6 then
                  puts "Requires: Server Username Password  Optional: Protocol Port"
                  puts "Example: clash > Connect-VIServer 127.0.0.1 administrator password https 443"
                elsif command.length==4 then
                  @clashcommandmapper = ClashCommandMapper.new :Server => command[1], :Username => command[2], :Password => command[3]
                  puts "Switched to vSphere Server #{command[1]}"
                elsif command.length==6 then
                  @clashcommandmapper = ClashCommandMapper.new :Server => command[1], :Username => command[2], :Password => command[3], :Protocol => command[4], :Port => command[5]
                  puts "Switched to vSphere Server #{command[1]}"
                else
                  puts command.length
                end

              elsif command[0] == "$result"
                @clashcommandmapper.directcall(command[1..command.length])

              elsif command[0] == "Get-VM" then
                if @clashcommandmapper!=nil then 
                  if command[1] == "-Server" then 
                    @clashcommandmapper.getvm(:Server => command[2])
                  else
                    @clashcommandmapper.getvm(:Name => command[1])
                  end
                else
                  puts "You must be connected to a System First"
                end
                  
              elsif ["test"].include?(command[0])
                puts "-ERR unknown command '#{command[0]}'"
              
              
              elsif command.length == 1
                 @clashcommandmapper.send(command[0].to_sym)

              else
                 @clashcommandmapper.send(command[0].to_sym, *command[1..command.length])
              end
            end

          end

        rescue ArgumentError => e
          puts e.message
          
        rescue NoMethodError => e
          puts e.message

        rescue RuntimeError => e
          puts e.message

        rescue Interrupt => e
          break

        end
      end
    end


    private


    def setup_autocompletion
      comp = proc { |s| Clash::Application::COMMANDS.grep( /^#{Regexp.escape(s)}/ ) }

      Readline.completion_append_character = " "
      Readline.completion_proc = comp
    end

  end
end