require 'emr/commands/abstract_ssh'

class Emr::Commands::Put < Emr::Commands::AbstractSsh
    attr_accessor :scp_opts

    def initialize(*args)
        super(*args)
    end

    def enact(client)
        super(client)
        if get_field(:dest) then
            exec "scp #{get_scp_opts} -i #{key_pair_file} #{@arg} hadoop@#{hostname}:#{get_field(:dest)}"
            else
            exec "scp #{get_scp_opts} -i #{key_pair_file} #{@arg} hadoop@#{hostname}:#{File.basename(@arg)}"
        end
    end
end
