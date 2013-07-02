require 'emr/commands/hbase'

class Emr::Commands::HbaseBackupSchedule < Emr::Commands::Hbase
  attr_accessor :full_backup_time_interval, :full_backup_time_unit, :backup_dir
  attr_accessor :start_time, :disable_full_backups, :disable
  attr_accessor :incremental_time_interval, :incremental_time_unit
  attr_accessor :disable_incremental_backups

  def initialize(*args)
    super(*args)
  end

  def validate
    super
    unless get_field(:disable_full_backups, false) || get_field(:disable_incremental_backups, false) then
        require(:backup_dir,    "--backup-dir path must be defined")
    end
  end

  def isDisable
    disable = get_field(:disable_full_backups, false) || get_field(:disable_incremental_backups, false)
    return disable
  end

  def steps
    args = get_step_args("--set-scheduled-backup", isDisable ? "false" : "true")
    if get_field(:full_backup_time_interval, nil) then
        args += ["--full-backup-time-interval", get_field(:full_backup_time_interval, nil)]
    end
    if get_field(:full_backup_time_unit, nil) then
        args += ["--full-backup-time-unit", get_field(:full_backup_time_unit, nil)]
    end
    if get_field(:start_time, "now") then
        args += ["--start-time", get_field(:start_time, "now")]
        if get_field(:start_time, "now") == "now" then
            puts "Setting StartTime for periodic backups to now, since you did not specify start-time"
        end
    end
    if get_field(:incremental_time_interval, nil) then
        args += ["--incremental-backup-time-interval", get_field(:incremental_time_interval, nil)]
    end
    if get_field(:incremental_time_unit, nil) then
        args += ["--incremental-backup-time-unit", get_field(:incremental_time_unit, nil)]
    end
    if isDisable then
        if get_field(:disable_full_backups) then
            args += ["--disable-full-backups"]
        end
        if get_field(:disable_incremental_backups) then
            args += ["--disable-incremental-backups"]
        end
    end

    step = {
        "Name"            => get_field(:step_name, "Modify Backup Schedule"),
        "ActionOnFailure" => get_field(:step_action, "CANCEL_AND_WAIT"),
        "HadoopJarStep"   => {
            "Jar" => get_field(:hbase_jar_path),
            "Args" => args
        }
    }
    return [step]
  end
end