require 'emr/commands/abstract_ssh'

class Emr::Commands::Logs < Emr::Commands::AbstractSsh
  attr_accessor :step_index

  INTERESTING_STEP_STATES = ['RUNNING', 'COMPLETED', 'FAILED']

  def enact(client)
    super(client)

    # find the last interesting step if that exists
    if get_field(:step_index) == nil then
        steps = resolve(jobflow_detail, "Steps")
        self.step_index = (0 ... steps.size).select { |index|
            INTERESTING_STEP_STATES.include?(resolve(steps, index, 'ExecutionStatusDetail', 'State'))
        }.last + 1
    end

    if get_field(:step_index) then
        logger.puts "Listing steps for step #{get_field(:step_index)}"
        exec "ssh -i #{key_pair_file} hadoop@#{hostname} cat /mnt/var/log/hadoop/steps/#{get_field(:step_index)}/{syslog,stderr,stdout}"
        else
        raise RuntimeError, "No steps that could have logs found in jobflow"
    end
  end
end