require 'emr/command'

class Emr::Commands::Eip < Emr::Command
  attr_accessor :no_wait, :instance_id, :key_pair_file, :jobflow_id, :jobflow_detail

  CLOSED_DOWN_STATES    = Set.new(%w(TERMINATED SHUTTING_DOWN COMPLETED FAILED))
  WAITING_OR_RUNNING_STATES = Set.new(%w(WAITING RUNNING))

  def initialize(*args)
    super(*args)
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
        raise RuntimeError, "Jobflow entered #{state} while waiting to assign Elastic IP"
      else
        logger.info("Jobflow is in state #{state}, waiting....")
        sleep(30)
        self.jobflow_detail = client.describe_jobflow_with_id(jobflow_id)
      end
    end
  end

  def region_from_az(az)
    md = az.match(/((\w+-)+\d+)\w+/)
    if md then
      md[1]
      else
      raise "Unable to convert Availability Zone '#{az}' to region"
    end
  end

  def ec2_endpoint_from_az(az)
    return "https://ec2.#{region_from_az(az)}.amazonaws.com"
  end

  def enact(client)
    self.jobflow_id = require_single_jobflow
    self.jobflow_detail = client.describe_jobflow_with_id(self.jobflow_id)
    if ! get_field(:no_wait) then
      wait_for_jobflow(client)
    end
    self.instance_id = self.jobflow_detail['Instances']['MasterInstanceId']
    if ! self.instance_id then
      logger.error("The master instance is not available yet for jobflow #{self.jobflow_id}. It might still be starting.")
      exit(-1)
    end

    az = self.jobflow_detail['Instances']['Placement']['AvailabilityZone']

    commands.global_options[:ec2_endpoint] = ec2_endpoint_from_az(az)

    self.key_pair_file = require(:key_pair_file, "Missing required option --key-pair-file for #{name}")
    eip = get_field(:arg)

    ec2_client = Ec2ClientWrapper.new(commands, logger)

    if ! eip then
      begin
        response = ec2_client.allocate_address()
        rescue Exception => e
        logger.error("Error during AllocateAddres: " + e.message)
        if get_field(:trace) then
          logger.puts(e.backtrace.join("\n"))
        end
        exit(-1)
      end

      eip = response['publicIp']
      logger.info("Allocated Public IP: #{eip}...")
    end

    begin
      response = ec2_client.associate_address(self.instance_id, eip)
      logger.info("Public IP: #{eip} was assigned to jobflow #{self.jobflow_id}")
      rescue Exception => e
      logger.error("Error during AssociateAddres: " + e.to_s)
      if get_field(:trace) then
        logger.puts(e.backtrace.join("\n"))
      end
      exit(-1)
    end

  end
end

