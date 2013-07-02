class Emr::Command
    attr_accessor :name, :description, :arg, :commands, :logger

    def initialize(name, description, arg, commands)
      @name = name
      @description = description
      @arg = arg
      @commands = commands
      @logger = commands.logger
    end

    # test any constraints that the command has
    def validate
    end

    # action the command
    def enact(client)
    end

    def option(argument_name, argument_symbol, value)
      var = self.send(argument_symbol)
      if var == nil then
        self.send((argument_symbol.to_s + "=").to_sym, value)
      elsif var.is_a?(Array) then
        var << value
      else
        raise RuntimeError, "Repeating #{argument_name} is not allowed, previous value was #{var.inspect}"
      end
    end

    def get_field(field_symbol, default_value=nil)
      value = nil
      if respond_to?(field_symbol) then
        value = self.send(field_symbol)
      end
      if value == nil then
        value = @commands.global_options[field_symbol]
      end
      default_field_symbol = ("default_" + field_symbol.to_s).to_sym
      if value == nil && respond_to?(default_field_symbol) then
        value = self.send(default_field_symbol)
      end
      if value == nil then
        value = default_value
      end
      return value
    end

    def require(field_symbol, error_msg)
      value = get_field(field_symbol)
      if value == nil then
        raise RuntimeError, error_msg
      end
      return value
    end

    def have(field_symbol)
      value = get_field(field_symbol)
      return value != nil
    end

    def has_value(obj, *args)
      while obj != nil && args.size > 1 do
        obj = obj[args.shift]
      end
      return obj == args[0]
    end

    def resolve(obj, *args)
      while obj != nil && args.size > 0 do
        obj = obj[args.shift]
      end
      return obj
    end

    def require_single_jobflow
      jobflow_ids = get_field(:jobflow)
      if jobflow_ids.size == 0 then
        raise RuntimeError, "A jobflow is required to use option #{name}"
      elsif jobflow_ids.size > 1 then
        raise RuntimeError, "The option #{name} can only act on a single jobflow"
      end
      return jobflow_ids.first
    end

    def is_govcloud?
      # !! = convert to boolean
      !!(get_field(:endpoint) =~ /us-gov-west-1/)
    end
end
