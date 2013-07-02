require 'emr/commands/step_processing'

class Emr::Commands::CreateJobFlow < Emr::Commands::StepProcessing
  attr_accessor :jobflow_name, :alive, :with_termination_protection, :visible_to_all_users,
  :instance_count, :slave_instance_type, :jobflow_role,
  :master_instance_type, :key_pair, :key_pair_file, :log_uri,
  :az, :ainfo, :ami_version, :with_supported_products,
  :hadoop_version, :plain_output, :instance_type,
  :instance_group_commands, :bootstrap_commands, :subnet_id,
  :supported_product_commands

  OLD_OPTIONS = [:instance_count, :slave_instance_type, :master_instance_type]
  # FIXME: add code to setup collapse instance group commands

  def default_hadoop_version
    if get_field(:ami_version) == "1.0" then
    "0.20"
    end
  end

  def initialize(*args)
    super(*args)
    @instance_group_commands = []
    @bootstrap_commands = []
    @supported_product_commands = []
  end

  def add_step_command(step)
    @step_commands << step
  end

  def add_bootstrap_command(bootstrap_command)
    @bootstrap_commands << bootstrap_command
  end

  def add_instance_group_command(instance_group_command)
    @instance_group_commands << instance_group_command
  end

  def add_supported_product_command(supported_product_command)
    @supported_product_commands << supported_product_command
  end

  def validate
    for step in step_commands do
    if step.is_a?(Emr::Commands::EnableDebugging) then
    if is_govcloud?
    raise RuntimeError, "Debugging is not supported in GovCloud."
    end
    require(:log_uri, "You must supply a logUri if you enable debugging when creating a job flow")
    end
    end

    for cmd in step_commands + instance_group_commands + bootstrap_commands + supported_product_commands do
    cmd.validate
    end

    if is_govcloud?
    require(:jobflow_role, "Missing --jobflow-role argument. An EC2 role must be used in GovCloud.")
    end

    jobflow_role = get_field(:jobflow_role)

    # Only do role validation and creation if AMI is 2.3 or later.
    ami_version = get_field(:ami_version)
    if jobflow_role and (ami_version.nil? or
       ami_version == "latest" or
       ami_version >= "2.3")
    validate_jobflow_role(jobflow_role)
    end
    end

    def role_exists?(role_name, client)
    begin
    client.get_instance_profile(:instance_profile_name => role_name)
    client.get_role(:role_name  => role_name)
    rescue AWS::Errors::Base => e
    if e.message =~ /NoSuchEntity/
    # No such instance profile/role.
    return false
    else
    # Some other error: reraise.
    raise e
    end
    end
    return true
    end

    def create_iam_client
    access_id = @commands.global_options[:aws_access_id]
    secret_key = @commands.global_options[:aws_secret_key]
    iam_endpoint = (is_govcloud?)? 'iam.us-gov.amazonaws.com' : 'iam.amazonaws.com'
    iam_client = AWS::IAM.new(:access_key_id => access_id,
        :secret_access_key => secret_key,
        :iam_endpoint => iam_endpoint)
    client = iam_client.client
    end

    def create_role_and_profile(jobflow_role, client)
    puts "Creating an EC2 role #{jobflow_role}..."

    # Steps:
    # 1. Create role (CreateRole)
    # 2. Add policy to role (PutRolePolicy)
    # 3. CreateInstanceProfile
    # 4. AddRoleToInstanceProfile

    client.create_role(:role_name => jobflow_role,
       :assume_role_policy_document => EC2Roles::ROLE_DEF)

    # Role name and policy name can be different.
    client.put_role_policy(:role_name => jobflow_role,
       :policy_name => jobflow_role,
       :policy_document => EC2Roles::POLICY_DOC)

    client.create_instance_profile(:instance_profile_name => jobflow_role)

    # IP name and role name are required to match by EC2.
    client.add_role_to_instance_profile(:instance_profile_name => jobflow_role,
        :role_name => jobflow_role)

    puts "Role created."
    end

    def validate_jobflow_role(jobflow_role)
    client = create_iam_client
    if not role_exists?(jobflow_role, client)
    if jobflow_role == EC2Roles::DEFAULT_EMR_ROLE
    create_role_and_profile(jobflow_role, client)
    else
    raise RuntimeError, "Specified EC2 role #{jobflow_role} does not exist. Please specify a valid EC2 role or use \"--jobflow-role #{EC2Roles::DEFAULT_EMR_ROLE}\"."
    end
    end
    end

    def enact(client)
    @jobflow = create_jobflow

    apply_jobflow_option(:ainfo, "AdditionalInfo")
    apply_jobflow_option(:key_pair, "Instances", "Ec2KeyName")
    apply_jobflow_option(:hadoop_version, "Instances", "HadoopVersion")
    apply_jobflow_option(:az, "Instances", "Placement", "AvailabilityZone")
    apply_jobflow_option(:log_uri, "LogUri")
    apply_jobflow_option(:ami_version, "AmiVersion")
    apply_jobflow_option(:subnet_id, "Instances", "Ec2SubnetId")
    apply_jobflow_option(:jobflow_role, "JobFlowRole")

    @jobflow["AmiVersion"] ||= "latest"

    self.step_commands = reorder_steps(@jobflow, self.step_commands)
    @jobflow["Steps"] = step_commands.map { |x| x.steps }.flatten

    setup_instance_groups
    @jobflow["Instances"]["InstanceGroups"] = instance_group_commands.map { |x| x.instance_group }
    bootstrap_action_index = 1
    if @jobflow["SupportedProducts"] then
    for product in @jobflow["SupportedProducts"] do
    if product[0..4] == 'mapr-' then
      action = {
      "Name" => "Install " + product,
      "ScriptBootstrapAction" => {
      "Path" => File.join(get_field(:apps_path), "thirdparty/mapr/scripts/mapr_emr_install.sh"),
      "Args" => ["--base-path", File.join(get_field(:apps_path), "thirdparty/mapr")]
      }
      }
      @jobflow["BootstrapActions"] << action
      bootstrap_action_index += 1
      break
    end
    end
    end

    for bootstrap_action_command in bootstrap_commands do
    if bootstrap_action_command.respond_to?(:modify_jobflow) then
      bootstrap_action_command.modify_jobflow(@jobflow)
    end
    actions = bootstrap_action_command.bootstrap_actions(bootstrap_action_index)
    for action in actions do
      @jobflow["BootstrapActions"] << action
      bootstrap_action_index += 1
    end
    end

    for supported_product_command in supported_product_commands do
      product = supported_product_command.supported_product
      @jobflow["NewSupportedProducts"] << product
    end

      run_result = client.run_jobflow(@jobflow)
      jobflow_id = run_result['JobFlowId']
      commands.global_options[:jobflow] << jobflow_id

      if have(:plain_output) then
      logger.puts jobflow_id
      else
      logger.puts "Created job flow " + jobflow_id
      end
    end

    def apply_jobflow_option(field_symbol, *keys)
    # Copy value from @global_options (via get_field) to @jobflow dictionary.
    value = get_field(field_symbol)
    if value != nil then
      map = @jobflow
      for key in keys[0..-2] do
      nmap = map[key]
      if nmap == nil then
      map[key] = {}
      nmap = map[key]
      end
      map = nmap
      end
      map[keys.last] = value
      end
    end

    def new_instance_group_command(role, instance_count, instance_type)
    igc = Emr::Commands::CreateInstanceGroup.new(
           "--instance-group ROLE", "Specify an instance group", role, commands
           )
    igc.instance_count = instance_count
    igc.instance_type = instance_type
    return igc
    end

    def have_role(instance_group_commands, role)
    instance_group_commands.select { |x|
      x.instance_role.upcase == role
    }.size > 0
    end

    def setup_instance_groups
      instance_groups = []
      if ! have_role(instance_group_commands, "MASTER") then
        mit = get_field(:master_instance_type, get_field(:instance_type, "m1.small"))
        master_instance_group = new_instance_group_command("MASTER", 1, mit)
        instance_group_commands << master_instance_group
      end
      if ! have_role(instance_group_commands, "CORE") then
        ni = get_field(:instance_count, 1).to_i
      if ni > 1 then
        sit = get_field(:slave_instance_type, get_field(:instance_type, "m1.small"))
        slave_instance_group = new_instance_group_command("CORE", ni-1, sit)
        slave_instance_group.instance_role = "CORE"
        instance_group_commands << slave_instance_group
      end
      else
      # Verify that user has not specified both --instance-group core and --num-instances
      if get_field(:instance_count) != nil then
        raise RuntimeError, "option --num-instances cannot be used when a core instance group is specified."
      end
      end
    end

    def create_jobflow
      @jobflow = {
      "Name"   => get_field(:jobflow_name, default_job_flow_name),
      "Instances" => {
        "KeepJobFlowAliveWhenNoSteps" => (get_field(:alive) ? "true" : "false"),
        "TerminationProtected"  => (get_field(:with_termination_protection) ? "true" : "false"),
        "InstanceGroups" => []
      },
      "Steps" => [],
      "BootstrapActions" => [],
      "VisibleToAllUsers" => (get_field(:visible_to_all_users) ? "true" : "false"),
      "NewSupportedProducts" => [],
      }
      products_string = get_field(:with_supported_products)
      if products_string then
      products = products_string.split(/,/).map { |s| s.strip }
      @jobflow["SupportedProducts"] = products
      end
      @jobflow
      end

      def default_job_flow_name
      name = "Development Job Flow"
      if get_field(:alive) then
      name += " (requires manual termination)"
      end
      return name
    end
end


