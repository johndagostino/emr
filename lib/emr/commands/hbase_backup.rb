require 'emr/commands/hbase'

class Emr::Commands::HbaseBackup < Emr::Commands::Hbase
  def initialize(*args)
    super(*args)
  end

  def steps
    step = {
      "Name"            => get_field(:step_name, "Backup HBase"),
      "ActionOnFailure" => get_field(:step_action, "CANCEL_AND_WAIT"),
      "HadoopJarStep"   => {
        "Jar" => get_field(:hbase_jar_path),
        "Args" => get_step_args("--backup")
      }
    }
    return [step]
  end
end
