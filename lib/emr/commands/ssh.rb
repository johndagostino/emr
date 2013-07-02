require 'emr/commands/abstract_ssh'

class Emr::Commands::Ssh < Emr::Commands::AbstractSsh
    attr_accessor :cmd, :ssh_opts, :scp_opts

    def initialize(*args)
        super(*args)
        if @arg =~ /j-[A-Z0-9]{8,20}/ then
            commands.global_options[:jobflow] << @arg
            else
            self.cmd = @arg
        end
    end

    def enact(client)
        super(client)
        exec "ssh #{get_ssh_opts} -i #{key_pair_file} hadoop@#{hostname} #{get_field(:cmd, "")}"
    end
end