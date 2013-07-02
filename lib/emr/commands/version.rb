require 'emr/command'

class Emr::Commands::Version < Emr::Command
  def enact(client)
    logger.puts "Version #{ELASTIC_MAPREDUCE_CLIENT_VERSION}"
  end
end


