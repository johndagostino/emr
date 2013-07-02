require 'emr/command'

class Emr::Commands::StepProcessing < Emr::Command
  attr_accessor :step_commands

  def initialize(*args)
    super(*args)
    @step_commands = []
  end

  def reorder_steps(jobflow, sc)
    new_step_commands = sc.dup
    for step_command in sc do
      new_step_commands = step_command.reorder_steps(jobflow, new_step_commands)
    end

    new_step_commands
  end
end
