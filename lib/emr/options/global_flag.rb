require 'emr/options/command'

class Emr::Options::GlobalFlag < Emr::Options::Command
    def attach(command)
        global_options = @commands.global_options
        value = global_options[@field_symbol]
        if value == nil then
            global_options[@field_symbol] = @arg
            else
            raise RuntimeError, "You may not specify #{@name} twice"
        end
    end
end