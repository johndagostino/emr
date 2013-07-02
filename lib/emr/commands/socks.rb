require 'emr/commands/abstract_ssh'

class Emr::Commands::Socks < Emr::Commands::AbstractSsh
    def enact(client)
        super(client)
        exec "ssh #{self.get_ssh_opts} -i #{key_pair_file} -ND 8157 hadoop@#{hostname}"
    end
end