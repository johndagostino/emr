require 'emr/options'

class Emr::Options::Command
  attr_accessor :name, :description, :arg, :parent_commands, :commands

  def initialize(name, description, arg, parent_commands, commands, field_symbol=nil, pattern=nil)
    @name = name
    @description = description
    @arg = arg
    @parent_commands = parent_commands
    @commands = commands
    @field_symbol = field_symbol
    @pattern = pattern
  end

  def attach(commands)
    for command in commands.reverse do
      command_name = command.name.split(/\s+/).first
      if @parent_commands.include?(command_name) || @parent_commands.include?(command.class) then
        return command
      end
    end
    raise RuntimeError, "Expected argument #{name} to follow one of #{parent_commands.join(", ")}"
  end
end
