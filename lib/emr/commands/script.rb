require 'emr/commands/step'

class Emr::Commands::Script < Emr::Commands::Step
  attr_accessor :script

  def steps
    step = {
      "Name"            => get_field(:step_name, "Run Hive Script"),
      "ActionOnFailure" => get_field(:step_action, "CANCEL_AND_WAIT"),
      "HadoopJarStep"   => {
        "Jar" => get_field(:script_runner_path),
        "Args" => [ get_field(:arg) ] + @args
      }
    }
    [ step ]
  end
end
