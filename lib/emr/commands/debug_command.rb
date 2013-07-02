require 'emr/commands/step'

class Emr::Commands::EnableDebugging < Emr::Commands::Step
  def steps
    step = {
      "Name"            => get_field(:step_name, "Setup Hadoop Debugging"),
      "ActionOnFailure" => get_field(:step_action, "TERMINATE_JOB_FLOW"),
      "HadoopJarStep"   => {
        "Jar" => get_field(:script_runner_path),
        "Args" => [ File.join(get_field(:enable_debugging_path), "fetch") ]
      }
    }
    return [ step ]
  end

  def reorder_steps(jobflow, sc)
    # remove enable debugging steps and add self at start
    new_sc = []
    for step_cmd in sc do
      if ! step_cmd.is_a?(Emr::Commands::EnableDebugging) then
        new_sc << step_cmd
      end
    end
    return [ self ] + new_sc
  end
end
