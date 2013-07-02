require 'emr/options/command'

class Emr::Options::Args < Emr::Options::Command
    def attach(commands)
        command = super(commands)
        command.args += @arg.split(",")
        return command
    end
end
