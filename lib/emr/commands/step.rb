require 'emr/command'

class Emr::Commands::Step < Emr::Command
  attr_accessor :args, :step_name, :step_action, :apps_path, :beta_path
  attr_accessor :script_runner_path, :pig_path, :hive_path, :pig_cmd, :hive_cmd, :enable_debugging_path

  def initialize(*args)
    super(*args)
    @args = []
  end

  def default_script_runner_path
    File.join(get_field(:apps_path), "libs/script-runner/script-runner.jar")
  end

  def default_pig_path
    File.join(get_field(:apps_path), "libs/pig/")
  end

  def default_pig_cmd
    [ File.join(get_field(:pig_path), "pig-script"), "--base-path",
      get_field(:pig_path) ]
  end

  def default_hive_path
    File.join(get_field(:apps_path), "libs/hive/")
  end

  def default_hive_cmd
    [ File.join(get_field(:hive_path), "hive-script"), "--base-path",
      get_field(:hive_path) ]
  end

  def default_resize_jobflow_cmd
    File.join(get_field(:apps_path), "libs/resize-job-flow/0.1/resize-job-flow.jar")
  end

  def default_enable_debugging_path
    File.join(get_field(:apps_path), "libs/state-pusher/0.1")
  end

  def validate
    super
    require(:apps_path, "--apps-path path must be defined")
  end

  def script_args
    if @arg then
      [ @arg ] + @args
    else
      @args
    end
  end

  def extra_args
    if @args != nil && @args.size > 0 then
      return ["--args"] + @args
    else
      return []
    end
  end

  def ensure_install_cmd(jobflow, sc, install_step_class)
    has_install = false
    install_step = install_step_class.new_from_commands(commands, self)
    if install_step.jobflow_has_install_step(jobflow) then
      return sc
    else
      new_sc = []
      has_install_pi = false
      for sc_cmd in sc do
        if sc_cmd.is_a?(install_step_class) then
          if has_install_pi then
            next
          else
            has_install_pi = true
          end
        end
        if sc_cmd.is_a?(self.class) then
          if ! has_install_pi then
            has_install_pi = true
            new_sc << install_step
            install_step.validate
          end
        end
        new_sc << sc_cmd
      end
    end
    return new_sc
  end

  def reorder_steps(jobflow, sc)
    return sc
  end
end

