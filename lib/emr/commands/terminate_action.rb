require 'emr/command'

class Emr::Commands::TerminateAction < Emr::Command
  def enact(client)
    job_flow = get_field(:jobflow)
    client.terminate_jobflows(job_flow)
    logger.puts "Terminated job flow " +  job_flow.join(" ")
  end
end
