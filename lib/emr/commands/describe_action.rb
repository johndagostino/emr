require 'emr/commands/abstract_list'

class Emr::Commands::DescribeAction < Emr::Commands::AbstractList
  def enact(client)
    result = super(client)
    logger.puts(JSON.pretty_generate(result))
  end
end
