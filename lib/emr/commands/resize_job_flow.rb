require 'emr/commands/step'

class Emr::Commands::ResizeJobflow < Emr::Commands::Step
  def validate
    super
  end

  def steps
    step = {
      "Name"            => get_field(:step_name, "Resize Job Flow Command"),
      "ActionOnFailure" => get_field(:step_action, "CANCEL_AND_WAIT"),
      "HadoopJarStep"   => {
        "Jar" => get_field(:resize_jobflow_cmd),
        "Args" => @args
      }
    }
    return [ step ]
  end
end
