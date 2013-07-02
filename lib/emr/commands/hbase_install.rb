require 'emr/commands/hbase'

class Emr::Commands::HbaseInstall < Emr::Commands::Hbase
  INVALID_INSTANCE_TYPES = Set.new(%w(m1.small c1.medium))

  def modify_jobflow(jobflow)
    jobflow["Instances"]["TerminationProtected"] = "true"
    jobflow["Instances"]["KeepJobFlowAliveWhenNoSteps"] = "true"
    for group in jobflow["Instances"]["InstanceGroups"] do
      instance_type = group["InstanceType"]
      if ! is_valid_instance_type(instance_type) then
        raise "Instance type #{instance_type} is not compatible with HBase, try adding --instance-type m1.large"
      end
    end
    if ! is_valid_ami_version(jobflow["AmiVersion"]) then
      raise "Ami version #{jobflow["AmiVersion"]} is not compatible with HBase"
    end
  end

  def is_valid_ami_version(ami_version)
    ami_version == "latest" || ami_version >= "2.1"
  end

  def is_valid_instance_type(instance_type)
    return ! INVALID_INSTANCE_TYPES.member?(instance_type)
  end

  def bootstrap_actions(index)
    action = {
      "Name" => get_field(:bootstrap_name, "Install HBase"),
      "ScriptBootstrapAction" => {
        "Path" => get_field(:install_script),
        "Args" => []
      }
    }
    return [ action ]
  end

  def steps
    step = {
      "Name"            => get_field(:step_name, "Start HBase"),
      "ActionOnFailure" => get_field(:step_action, "CANCEL_AND_WAIT"),
      "HadoopJarStep"   => {
        "Jar" => get_field(:hbase_jar_path),
        "Args" => [ "emr.hbase.backup.Main", "--start-master" ]
      }
    }
    return [step]
  end
end
