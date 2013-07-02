require 'emr/commands/abstract_instance_group'

class Emr::Commands::ModifyInstanceGroup < Emr::Commands::AbstractInstanceGroup
  attr_accessor :jobflow_detail, :jobflow_id

  def validate
    if get_field(:instance_group_id) == nil then
      if ! ["CORE", "TASK"].include?(get_field(:instance_role)) then
        raise RuntimeError, "Invalid argument to #{name}, #{@arg} is not valid"
      end
      if get_field(:jobflow, []).size == 0 then
        raise RuntimeError, "You must specify a jobflow when using #{name} and specifying a role #{instance_role}"
      end
    end
    require(:instance_count, "Option #{name} is missing --instance-count")
  end

  def enact(client)
    if get_field(:instance_group_id) == nil then
      self.jobflow_id = require_single_jobflow
      self.jobflow_detail = client.describe_jobflow_with_id(self.jobflow_id)
      matching_instance_groups =
      jobflow_detail['Instances']['InstanceGroups'].select { |x| x['InstanceRole'] == instance_role }
      require_singleton_array(matching_instance_groups, "instance group with role #{instance_role}")
      self.instance_group_id = matching_instance_groups.first['InstanceGroupId']
    end
    options = {
      'InstanceGroups' => [{
        'InstanceGroupId' => get_field(:instance_group_id),
        'InstanceCount' => get_field(:instance_count)
      }]
    }
    client.modify_instance_groups(options)
    ig_modified = nil
    if get_field(:instance_role) != nil then
      ig_modified = get_field(:instance_role)
      else
      ig_modified = get_field(:instance_group_id)
    end
    logger.puts("Modified instance group " + ig_modified)
  end
end
