require 'emr/commands/step_processing'

class Emr::Commands::AddJobFlowSteps < Emr::Commands::StepProcessing
  def add_step_command(step)
    @step_commands << step
  end

  def validate
    for cmd in step_commands do
      cmd.validate
    end
  end

  def enact(client)
    jobflow_id = require_single_jobflow
    jobflow = client.describe_jobflow_with_id(jobflow_id)
    self.step_commands = reorder_steps(jobflow, self.step_commands)
    jobflow_steps = step_commands.map { |x| x.steps }.flatten
    client.add_steps(jobflow_id, jobflow_steps)
    logger.puts("Added jobflow steps")
  end
end

