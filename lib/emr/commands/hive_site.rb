require 'emr/commands/hive'

class Emr::Commands::HiveSite < Emr::Commands::Hive
  def steps
      step = {
          "Name"            => get_field(:step_name, "Install Hive Site Configuration"),
          "ActionOnFailure" => get_field(:step_action, "CANCEL_AND_WAIT"),
          "HadoopJarStep"   => {
              "Jar" => get_field(:script_runner_path),
              "Args" => get_field(:hive_cmd) + [ "--install-hive-site", "--hive-site=#{@arg}" ] +
              extra_args + get_version_args(true)
          }
      }
      return [ step ]
  end

  def reorder_steps(jobflow, sc)
      return ensure_install_cmd(jobflow, sc, HiveInteractiveCommand)
  end
end
