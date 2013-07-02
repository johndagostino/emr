require 'emr/options/command'

class Emr::Options::InstanceType < Emr::Options::Command
  def attach(commands)
    command = super(commands)
    command.instance_type = @arg
    return command
  end
end
