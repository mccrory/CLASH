require 'java'
require 'pp'
require File.join(File.dirname(__FILE__), 'dom4j-1.6.1.jar') 
require File.join(File.dirname(__FILE__), 'vijava2120100715.jar')

import java.net.URL

module VIJava
  include_package "com.vmware.vim25.mo"
end

class ConnectVIServer

  def connect(options)

    puts "vSphere options passed are : #{options}"
    puts "Server :  #{options[:Server]}"
    puts "Username :  #{options[:Username]}"
    puts "Password :  #{options[:Password]}"
    puts "Protocol :  #{options[:Protocol]}"
    puts "Port :  #{options[:Port]}"
    
    @Server=options[:Server]
    @Username=options[:Username]
    @Password=options[:Password]
    @Protocol=options[:Protocol]
    @Port=options[:Port]
    
    $viserver = VIJava::ServiceInstance.new(URL.new("#{@Protocol}://#{@Server}:#{@Port}/sdk"), "#{@Username}", "#{@Password}", true)
    $Result=$viserver
    $ResultHistory=[]
    $ResultHistory<<$Result
  end

  def disconnect
    $viserver.getServerConnection().logout()
    puts "Disconnected from vSphere Server"
  end
end

class MethodPasser

    def run(options)
      if options.length>0 then
        options.delete_if {|opts| opts==(/\n/) }
      end
      
      @ResultPasser=$Result
      if @ResultPasser==nil then
        puts "Value of $Result is nil nothing passed"
      else
        if options==nil then
          puts @ResultPasser
        else
          begin
            @Passer=options
            pp @ResultPasser.send(@Passer.to_s)
            
          rescue InvalidMethod
            puts "Method is not Valid"
            return
          
          rescue NameError
            puts "Invalid Method Name"
            return
          
          rescue InvalidArgument
            put "Bad or Invalid Argument"
            return
            
          rescue RuntimeError => e
            puts e.message

          rescue Interrupt => e
            return
          end
        $ResultHistory<<$Result
        end
      end
    end
end

class GetVM
    attr_accessor :Name, :Datastore, :DistributedSwitch, :Id, :Location, :NoRecursion, :Server
    attr_accessor :ReturnedResult, :ReturnedPreviousResult
    
    def run
# Create a connection to the vSphere Root Folder so that we can traverse things
      rootFolder = $viserver.getRootFolder()
# If the Name Property has been set on the GetVM Object, start
      if @Name!=nil then 
# Create an Instance Variable/Object Collection called @vms and populate it with any VMs that it finds
        @vms=VIJava::InventoryNavigator.new(rootFolder).searchManagedEntities("VirtualMachine")
# Use the "each" iterator to look at each Object in the Collection and use .getName to see if the name matches the @Name accessor
        @vms.each {|vmiter| if vmiter.getName()==@Name then 
# Set the $Result variable to the Current VM (since we found a match above) 
        $Result=vmiter
# Since this is the first $Result population and there is no Previous Result, set the $PreviousResult to the same value as $Result
        $ResultHistory<<$Result 
# Create an instance variable from our $Result value and apply the .getConfig().getGuestFullName() object result
        @printiter=$Result.getConfig().getGuestFullName()
# Use the "each" Ruby iterator on our instance variable to print out the result of the method called in the line above
        @printiter.each {|piter| pp piter}
# Close the @vms.each iteration we opened earlier
                  end}
# Evaluate the GetVM Object to see if the @Server Accessor has a value if a Name wasn't passed & Follow the same algorithm as above
      elsif @Server!=nil then
        @vms=VIJava::InventoryNavigator.new(rootFolder).searchManagedEntities("HostSystem")
        @vms.each {|vmiter| if vmiter.getName()==@Server then
          $Result=vmiter
          $ResultHistory<<$Result 
          @printiter=$Result.getVms()
          @printiter.each {|piter| pp piter.getName()}
                  end}
      end 
end

class StartVM
  attr_accessor :Name, :Async
  attr_accessor :ReturnedResult, :ReturnedPreviousResult
  
  def run
    rootFolder = $viserver.getRootFolder()
    if @Result!=nil then
      @Name=@Result.getName()
    end
    if @Name!=nil then    
      @vms=VIJava::InventoryNavigator.new(rootFolder).searchManagedEntity("VirtualMachine", @Name)
      task=@vms.powerOnVM_Task()
      if @Async!=nil then
        if task.waitForMe()=="success" then
          puts "VM Powered On"
            $PreviousResult=$Result
            $Result="success"
          end
        else
          puts "!VM Power On Failure!"
          if $Result==nil then 
            $Result="failure"
            $PreviousResult=$Result 
          else 
            $PreviousResult=$Result
            $Result="failure"
          end
        end
      else
        puts "VM Powered On"
        if $Result==nil then 
          $Result="success"
          $PreviousResult=$Result 
        else 
          $PreviousResult=$Result
          $Result="success"
        end
      end
    end
    @ReturnedResult=$Result
    @ReturnedPreviousResult=$PreviousResult
  end
end

class StopVM
  attr :Name, true
  attr :Async, true
  def find
    if @Name != nil then
      rootFolder = $viserver.getRootFolder()
      @vms=VIJava::InventoryNavigator.new(rootFolder).searchManagedEntity("VirtualMachine", @Name)
      task = @vms.powerOffVM_Task()
      if @Async==nil then
        if task.waitForMe()=="success" then puts "VM Powered Off" end
      end
    end
  end
end

class SuspendVM
  attr :Name, true
  attr :Async, true
  def find
    if @Name != nil then
      rootFolder = $viserver.getRootFolder()
      @vms=VIJava::InventoryNavigator.new(rootFolder).searchManagedEntity("VirtualMachine", @Name)
      task = @vms.suspendVM_Task()
      if @Async==nil then
        if task.waitForMe()=="success" then puts "VM Suspended" end
      end
    end
  end
end

class RestartVM
  attr :Name, true
  attr :Async, true
  def find
    if @Name != nil then
      rootFolder = $viserver.getRootFolder()
      @vms=VIJava::InventoryNavigator.new(rootFolder).searchManagedEntity("VirtualMachine", @Name)
      task = @vms.resetVM_Task()
      if @Async==nil then
        if task.waitForMe()=="success" then puts "VM Restarted" end
      end
    end
  end
end
