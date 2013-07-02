require 'emr/options/command'

class Emr::Options::Arg < Emr::Options::Command
    def attach(commands)
        command = super(commands)
        command.args << @arg
        return command
    end
end