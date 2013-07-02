require 'emr/commands/hbase'

class Emr::Commands::HbaseRestore < Emr::Commands::Hbase
  def initialize(*args)
      super(*args)
  end

  def steps
    step = {
        "Name"            => get_field(:step_name, "Restore HBase"),
        "ActionOnFailure" => get_field(:step_action, "CANCEL_AND_WAIT"),
        "HadoopJarStep"   => {
            "Jar" => get_field(:hbase_jar_path),
            "Args" => get_step_args("--restore")
        }
    }
    [step]
  end

  def reorder_steps(jobflow, sc)
    new_sc = []
    for cmd in sc do
        if ! cmd.is_a?(HBaseRestore) then
            new_sc << cmd
        end
    end
    [ self ] + new_sc
  end
end