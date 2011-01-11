require 'rubygems'
require File.join(File.dirname(__FILE__), 'vsphere.rb')

class ClashCommandMapper
  def initialize(options)
          if options[:Server]!=nil then puts "Server #{options[:Server]}"
            else 
          puts "Must Supply A Server to Connect To ex: --Server 127.0.0.1"
          return
          end
     if options[:Username]!=nil then puts "Username #{options[:Username]}"
       else
     puts "Must Supply A Username ex: --Username administrator"
     return
     end
          if options[:Password]!=nil then puts "Password ********"
            else 
          puts "Must Supply A Password ex: --Password thepassword"
          return
          end
          if options[:Protocol]!=nil then puts "Protocol #{options[:Protocol]}"
            else
          options[:Protocol]="https"
          puts "No Protocol Specified - Assuming HTTPS"
          end
          if options[:Port]!=nil then puts "Port #{options[:Port]}"
            else 
          options[:Port]=443
          puts "No Port Specified - Assuming 443"
          end
    @vsphere = ConnectVIServer.new
    $startingoptions = options    
    @vsphere.connect $startingoptions
    
  end
	
	def disconnect
	  @vsphere.disconnect
	end
	
	def getvm(options)
	  command = GetVM.new
	  if options[:Name]!=nil then 
	    command.Name=options[:Name]
	    command.run
	  end
	  if options[:Server]!=nil then 
	    command.Server=options[:Server]
	    command.run
	  end
	end
	
	def directcall(options)
	  if options[0]==nil then
	    puts $Result
	    return
	  end
	  if options[0]=="$parent" then
	    puts "Going back to #{$ResultHistory.last}"
	    $Result=$ResultHistory.pop
	    return
	  end
	  if options[0]=="$" then
	    puts "Methods Include:"
	    $Result.methods.sort.each { |method| puts "Method Name: #{method} "}
	  elsif options[0]=="$.get" then
	    puts "Get Methods Include:"
	    $Result.methods.each { |method| if method.rindex('get')!=nil then pp method end }
	  elsif options[0]=="$.set" then
	    puts "Set Methods Include:"
	    $Result.methods.each { |method| if method.rindex('set')!=nil then pp method end }
	  elsif options[0]=="$.find" then
	    puts "Found Methods:"
	    $Result.methods.each { |method| if method.rindex(options[1].to_s)!=nil then pp method end }
	  else
	    command = MethodPasser.new
	    command.run(options)
    end
	end
	
end
