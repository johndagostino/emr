require 'emr/options/command'

class Emr::Options::Global < Emr::Options::Command
    def attach(commands)
        global_options = @commands.global_options
        value = global_options[@field_symbol]
        if value.is_a?(Array) then
            value << @arg
            elsif value == nil then
            global_options[@field_symbol] = @arg
            else
            raise RuntimeError, "You may not specify #{@name} twice"
        end
        return nil
    end
end