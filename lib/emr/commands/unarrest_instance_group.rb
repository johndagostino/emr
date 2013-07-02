require 'emr/commands/abstract_instance_group'

class Emr::Commands::UnarrestInstanceGroup < Emr::Commands::AbstractInstanceGroup

  attr_accessor :jobflow_id, :jobflow_detail

  def validate
    require_single_jobflow
    if get_field(:instance_group_id) == nil then
      if ! ["CORE", "TASK"].include?(get_field(:instance_role)) then
        raise RuntimeError, "Invalid argument to #{name}, #{@arg} is not valid"
      end
    end
  end

  def enact(client)
    self.jobflow_id = require_single_jobflow
    self.jobflow_detail = client.describe_jobflow_with_id(self.jobflow_id)

    matching_instance_groups = nil
    if get_field(:instance_group_id) == nil then
      matching_instance_groups =
      jobflow_detail['Instances']['InstanceGroups'].select { |x| x['InstanceRole'] == instance_role }
      else
      matching_instance_groups =
      jobflow_detail['Instances']['InstanceGroups'].select { |x| x['InstanceGroupId'] == get_field(:instance_group_id) }
    end

    require_singleton_array(matching_instance_groups, "instance group with role #{instance_role}")
    instance_group_detail = matching_instance_groups.first
    self.instance_group_id = instance_group_detail['InstanceGroupId']
    self.instance_count = instance_group_detail['InstanceRequestCount']

    options = {
      'InstanceGroups' => [{
        'InstanceGroupId' => get_field(:instance_group_id),
        'InstanceCount' => get_field(:instance_count)
      }]
    }
    client.modify_instance_groups(options)
    logger.puts "Unarrested instance group #{get_field(:instance_group_id)}."
  end
end
