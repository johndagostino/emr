require 'emr/command'

class Emr::Commands::AbstractSsh < Emr::Command
  attr_accessor :no_wait, :dest, :hostname, :key_pair_file, :jobflow_id, :jobflow_detail
  attr_accessor :cmd, :ssh_opts, :scp_opts

  CLOSED_DOWN_STATES    = Set.new(%w(TERMINATED SHUTTING_DOWN COMPLETED FAILED))
  WAITING_OR_RUNNING_STATES = Set.new(%w(WAITING RUNNING))

  def initialize(*args)
    super(*args)
    @ssh_opts = ["-o ServerAliveInterval=10", "-o StrictHostKeyChecking=no"]
    @scp_opts = ["-r", "-o StrictHostKeyChecking=no"]
  end

  def opts
    (get_field(:ssh_opts, []) + get_field(:scp_opts, [])).join(" ")
  end

  def get_ssh_opts
    get_field(:ssh_opts, []).join(" ")
  end

  def get_scp_opts
    get_field(:scp_opts, []).join(" ")
  end

  def exec(cmd)
    commands.exec(cmd)
  end

  def wait_for_jobflow(client)
    while true do
      state = resolve(self.jobflow_detail, "ExecutionStatusDetail", "State")
      if WAITING_OR_RUNNING_STATES.include?(state) then
        break
        elsif CLOSED_DOWN_STATES.include?(state) then
        raise RuntimeError, "Jobflow entered #{state} while waiting to ssh"
        else
        logger.info("Jobflow is in state #{state}, waiting....")
        sleep(30)
        self.jobflow_detail = client.describe_jobflow_with_id(jobflow_id)
      end
    end
  end

   def enact(client)
     self.jobflow_id = require_single_jobflow
     self.jobflow_detail = client.describe_jobflow_with_id(self.jobflow_id)
     if ! get_field(:no_wait) then
       wait_for_jobflow(client)
     end
     self.hostname = self.jobflow_detail['Instances']['MasterPublicDnsName']
     self.key_pair_file = require(:key_pair_file, "Missing required option --key-pair-file for #{name}")
   end
end
