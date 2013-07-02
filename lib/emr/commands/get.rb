require 'emr/commands/abstract_ssh'

class Emr::Commands::Get < Emr::Commands::AbstractSsh
  attr_accessor :scp_opts

  def initialize(*args)
      super(*args)
  end

  def enact(client)
    super(client)
    if get_field(:dest) then
      exec "scp #{self.get_scp_opts} -i #{key_pair_file} hadoop@#{hostname}:#{@arg} #{get_field(:dest)}"
    else
      exec "scp #{self.get_scp_opts} -i #{key_pair_file} hadoop@#{hostname}:#{@arg} #{File.basename(@arg)}"
    end
  end
end