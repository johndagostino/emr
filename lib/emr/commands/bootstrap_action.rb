require 'emr/command'

class Emr::Commands::BootstrapAction < Emr::Command
  attr_accessor :bootstrap_name, :args

  def initialize(*args)
    super(*args)
    @args = []
  end

  def bootstrap_actions(index)
    action = {
      "Name" => get_field(:bootstrap_name, "Bootstrap Action #{index}"),
      "ScriptBootstrapAction" => {
        "Path" => @arg,
        "Args" => @args
      }
    }
    return [ action ]
  end
end
