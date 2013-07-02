require 'emr/commands/pig'

class Emr::Commands::PigInteractive < Emr::Commands::Pig
  def self.new_from_commands(commands, parent)
    sc = self.new("--pig-interactive", "Run a jobflow with Pig Installed", nil, commands)
    sc.step_action = parent.step_action
    return sc
  end

  def steps
    step = {
      "Name"            => get_field(:step_name, "Setup Pig"),
      "ActionOnFailure" => get_field(:step_action, "TERMINATE_JOB_FLOW"),
      "HadoopJarStep"   => {
        "Jar" => get_field(:script_runner_path),
        "Args" => get_field(:pig_cmd) + ["--install-pig"] + extra_args +
        get_version_args(false)
      }
    }
    return [ step ]
  end

  def jobflow_has_install_step(jobflow)
    install_steps = jobflow['Steps'].select do |step|
    step["ExecutionStatusDetail"]["State"] != "FAILED" &&
      has_value(step, 'StepConfig', 'HadoopJarStep', 'Jar', get_field(:script_runner_path)) &&
      has_value(step, 'StepConfig', 'HadoopJarStep', 'Args', 3, "--install-pig")
    end
    return install_steps.size > 0
  end
end
