require 'emr/commands/hive'

class Emr::Commands::HiveInteractive < Emr::Commands::Hive
  def steps
    step = {
      "Name" => get_field(:step_name, "Setup Hive"),
      "ActionOnFailure" => get_field(:step_action, "TERMINATE_JOB_FLOW"),
      "HadoopJarStep" => {
        "Jar" => get_field(:script_runner_path),
        "Args" => get_field(:hive_cmd) + [ "--install-hive" ] +
          get_version_args(false) + extra_args
      }
    }
    [ step ]
  end

  def jobflow_has_install_step(jobflow)
    install_steps = jobflow['Steps'].select do |step|
      step["ExecutionStatusDetail"]["State"] != "FAILED" &&
      has_value(step, 'StepConfig', 'HadoopJarStep', 'Jar', get_field(:script_runner_path)) &&
      has_value(step, 'StepConfig', 'HadoopJarStep', 'Args', 3, "--install-hive") &&
      has_value(step, 'StepConfig', 'HadoopJarStep', 'Args', 5, get_version_args(true)[1])
    end
    return install_steps.size > 0
  end

  def self.new_from_commands(commands, parent)
    sc = self.new("--hive-interactive", "Run a jobflow with Hive Installed", nil, commands)
    sc.hive_versions = parent.hive_versions
    sc.step_action = parent.step_action
    return sc
  end
end
