require 'emr/options/command'

class Emr::Options::Param < Emr::Options::Command
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
