require 'emr/commands/pig'
require 'emr/commands/pig_interactive'

class Emr::Commands::PigScript < Emr::Commands::Pig
  def steps
    mandatory_args = [ "--run-pig-script", "--args", "-f" ]
    if @arg then
      mandatory_args << @arg
    end
    step = {
      "Name"            => get_field(:step_name, "Run Pig Script"),
      "ActionOnFailure" => get_field(:step_action, "CANCEL_AND_WAIT"),
      "HadoopJarStep"   => {
        "Jar" => get_field(:script_runner_path),
        "Args" => get_field(:pig_cmd) + get_version_args(true) + mandatory_args + @args
      }
    }
    return [ step ]
  end


  def reorder_steps(jobflow, sc)
    return ensure_install_cmd(jobflow, sc, Emr::Commands::PigInteractive)
  end
end
