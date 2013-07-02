require 'emr/options/command'

class Emr::Options::Flag < Emr::Options::Command

  def initialize(name, description, arg, parent_commands, commands, field_symbol)
    super(name, description, arg, parent_commands, commands)
    @field_symbol = field_symbol
  end

  def attach(commands)
    command = super(commands)
    command.option(@name, @field_symbol, true)
  end
end
