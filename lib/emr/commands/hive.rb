require 'emr/commands/step'

class Emr::Commands::Hive < Emr::Commands::Step
  attr_accessor :hive_versions

  def get_version_args(require_single_version)
      versions = get_field(:hive_versions, nil)
      if versions == nil then
          return ["--hive-versions", "latest"]
      end
      if require_single_version then
          if versions.split(",").size != 1 then
              raise RuntimeError, "Only one version my be specified for --hive-script"
          end
      end
      return ["--hive-versions", versions]
  end
end