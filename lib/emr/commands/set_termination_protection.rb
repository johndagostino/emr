require 'emr/command'

class Emr::Commands::SetTerminationProtection < Emr::Command
  def enact(client)
    job_flow = get_field(:jobflow)
    termination_protected = @arg == 'true'
    client.set_termination_protection(job_flow, termination_protected)
    logger.puts "#{termination_protected ? "Disabled":"Enabled"} job flow termination " +  job_flow.join(" ")
  end
end
