require 'emr/commands/abstract_instance_group'

class Emr::Commands::AddInstanceGroup < Emr::Commands::AbstractInstanceGroup
  def validate
    if ! ["TASK"].include?(get_field(:instance_role)) then
      raise RuntimeError, "Invalid argument to #{name}, expected 'task'"
    end
    require(:instance_type, "Option #{name} is missing --instance-type")
    require(:instance_count, "Option #{name} is missing --instance-count")
  end

  def enact(client)
    client.add_instance_groups(
                   'JobFlowId' => require_single_jobflow, 'InstanceGroups' => [instance_group]
                   )
    logger.puts("Added instance group " + get_field(:instance_role))
  end
end
