require 'emr/options/command'

class Emr::Options::WithArg < Emr::Options::Command
  def attach(commands)
    command = super(commands)
    if @pattern && ! @arg.match(@pattern) then
      raise RuntimeError, "Expected argument to #{@name} to match #{@pattern.inspect}, but it didn't"
    end
    command.option(@name, @field_symbol, @arg)
    return command
  end
end
