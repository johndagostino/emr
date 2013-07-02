require 'emr/command'

class Emr::Commands::WaitForSteps < Emr::Command
  attr_accessor :jobflow_id, :jobflow_detail

  def all_steps_terminated(client)
    self.jobflow_detail = client.describe_jobflow_with_id(self.jobflow_id)
    steps = resolve(self.jobflow_detail, "Steps")

    if steps.empty? != true && ["PENDING", "RUNNING"].include?(steps.last["ExecutionStatusDetail"]["State"])
      logger.info("Last step #{steps.last["StepConfig"]["Name"]} is in state #{steps.last["ExecutionStatusDetail"]["State"]}, waiting....")
      return false
    end

    return true
  end

  def enact(client)
    self.jobflow_id = require_single_jobflow

    while ! all_steps_terminated(client) do
      sleep(30)
    end
  end
end

