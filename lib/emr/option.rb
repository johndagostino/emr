



 




  class InstanceTypeOption < CommandOption
    def attach(commands)
      command = super(commands)
      command.instance_type = @arg
      return command
    end
  end

  class OptionWithArg < CommandOption
    def attach(commands)
      command = super(commands)
      if @pattern && ! @arg.match(@pattern) then
        raise RuntimeError, "Expected argument to #{@name} to match #{@pattern.inspect}, but it didn't"
      end
      command.option(@name, @field_symbol, @arg)
      return command
    end
  end

  class FlagOption < CommandOption

    def initialize(name, description, arg, parent_commands, commands, field_symbol)
      super(name, description, arg, parent_commands, commands)
      @field_symbol = field_symbol
    end

    def attach(commands)
      command = super(commands)
      command.option(@name, @field_symbol, true)
    end
  end

  class ParamOption < CommandOption
    def initialize(*args)
      super(*args)
      @params = []
    end

    def attach(commands)
      command = super(commands)
      if match = @arg.match(/([^=]+)=(.*)/) then
        command.option(@name, @field_symbol, { :key => match[1], :value => match[2] })
      else
        raise RuntimeError, "Expected '#{@arg}' to be in the form VARIABLE=VALUE"
      end
      return command
    end
  end

 