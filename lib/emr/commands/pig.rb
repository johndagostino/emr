require 'emr/commands/step'

class Emr::Commands::Pig < Emr::Commands::Step
  attr_accessor :pig_versions

  def get_version_args(require_single_version)
    versions = get_field(:pig_versions, nil)
    if versions == nil then
      # Pass latest by default.
      return ["--pig-versions", "latest"]
    end
    if require_single_version then
      if versions.split(",").size != 1 then
        raise RuntimeError, "Only one version my be specified for --pig-script"
      end
    end
    return ["--pig-versions", versions]
  end
end
