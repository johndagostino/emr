require 'emr/options/command'

class Emr::Options::InstanceCount < Emr::Options::Command
    def attach(commands)
        command = super(commands)
        command.instance_count = @arg.to_i
        return command
    end
end