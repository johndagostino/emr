require 'emr/commands/hive'

class Emr::Commands::HiveScript < Emr::Commands::Hive
  def steps
      mandatory_args = [ "--run-hive-script", "--args", "-f" ]
      if @arg then
          mandatory_args << @arg
      end
      step = {
          "Name"            => get_field(:step_name, "Run Hive Script"),
          "ActionOnFailure" => get_field(:step_action, "CANCEL_AND_WAIT"),
          "HadoopJarStep"   => {
              "Jar" => get_field(:script_runner_path),
              "Args" => get_field(:hive_cmd) + get_version_args(true) + mandatory_args + @args
          }
      }
      [ step ]
  end

  def reorder_steps(jobflow, sc)
      return ensure_install_cmd(jobflow, sc, Emr::Commands::HiveInteractive)
  end
end