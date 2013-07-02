require 'emr/commands/abstract_instance_group'

class Emr::Commands::CreateInstanceGroup < Emr::Commands::AbstractInstanceGroup
  def validate
    if ! ["MASTER", "CORE", "TASK"].include?(get_field(:instance_role)) then
      raise RuntimeError, "Invalid argument to #{name}, expected master, core or task"
    end
    require(:instance_type, "Option #{name} is missing --instance-type")
    require(:instance_count, "Option #{name} is missing --instance-count")
  end
end
