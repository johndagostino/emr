require 'emr/command'

class Emr::Commands::Help < Emr::Command
  def enact(client)
    logger.puts commands.opts
  end
end
