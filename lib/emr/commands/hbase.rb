require 'emr/command'

class Emr::Commands::Hbase < Emr::Command
  attr_accessor :hbase_jar_path, :install_script, :backup_dir, :backup_version, :consistent
  attr_accessor :apps_path

  def initialize(*args)
    super(*args)
  end

  def hbase_jar_path
    "/home/hadoop/lib/hbase-0.92.0.jar"
  end

  def install_script
    File.join(get_field(:apps_path), "bootstrap-actions/setup-hbase")
  end

  def get_step_args(cmd, cmd_arg=nil)
    args = [ "emr.hbase.backup.Main", cmd ]
    if cmd_arg != nil then
      args << cmd_arg
    end
    if get_field(:backup_dir, nil) then
      args += [ "--backup-dir", get_field(:backup_dir) ]
    end
    if get_field(:backup_version, nil) then
      args += [ "--backup-version", get_field(:backup_version) ]
    end
    if get_field(:consistent, nil) then
      args += [ "--consistent" ]
    end
    return args
  end

  def reorder_steps(jobflow, sc)
    return sc
  end
end
