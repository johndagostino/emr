require 'emr/command'

class Emr::Commands::SetVisibleToAllUsers < Emr::Command
  def enact(client)
    job_flow = get_field(:jobflow)
    visible_to_all_users = @arg == 'true'
    client.set_visible_to_all_users(job_flow, visible_to_all_users)
    logger.puts "#{visible_to_all_users ? "Enabled" : "Disabled"} job flow visibility to all IAM users" + job_flow.join(" ")
  end
end
