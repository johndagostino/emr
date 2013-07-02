require 'emr/commands/step'

class Emr::Commands::JarStep < Emr::Commands::Step
  attr_accessor :main_class

  def steps
    step = {
        "Name"            => get_field(:step_name, "Example Jar Step"),
        "ActionOnFailure" => get_field(:step_action, "CANCEL_AND_WAIT"),
        "HadoopJarStep"   => {
            "Jar"  => get_field(:arg),
            "Args" => get_field(:args, [])
        }
    }
    if get_field(:main_class) then
        step["HadoopJarStep"]["MainClass"] = get_field(:main_class)
    end
    return [ step ]
  end
end