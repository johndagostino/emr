require 'emr/commands_list'
require 'emr/credentials'

require 'emr/commands'
require 'emr/commands/describe_action'
require 'emr/commands/hbase'
require 'emr/commands/hive_script'
require 'emr/commands/list_action'
require 'emr/commands/logs'
require 'emr/commands/modify_instance_group'
require 'emr/commands/resize_job_flow'
require 'emr/commands/wait_for_steps'
require 'emr/commands/debug_command'
require 'emr/commands/hbase_backup'
require 'emr/commands/hbase_install'
require 'emr/commands/hive_interactive'
require 'emr/commands/hive_site'
require 'emr/commands/jar_setup'
require 'emr/commands/json_step'
require 'emr/commands/pig_interactive'
require 'emr/commands/pig_script'
require 'emr/commands/print_hive_version'
require 'emr/commands/script'
require 'emr/commands/unarrest_instance_group'
require 'emr/commands/epi'
require 'emr/commands/get'
require 'emr/commands/socks'
require 'emr/commands/ssh'
require 'emr/commands/stream_step'
require 'emr/commands/terminate_action'
require 'emr/commands/abstract_instance_group'
require 'emr/commands/abstract_list'
require 'emr/commands/abstract_ssh'
require 'emr/commands/add_instance_group'
require 'emr/commands/add_job_flow_steps'
require 'emr/commands/bootstrap_action'
require 'emr/commands/create_instance_group'
require 'emr/commands/create_job_flow'
require 'emr/commands/hbase_backup_schedule'
require 'emr/commands/hbase_restore'
require 'emr/commands/help'
require 'emr/commands/hive'
require 'emr/commands/pig'
require 'emr/commands/put'
require 'emr/commands/set_termination_protection'
require 'emr/commands/supported_product'
require 'emr/commands/set_visible_to_all'
require 'emr/commands/step'
require 'emr/commands/step_processing'
require 'emr/commands/version'

require 'emr/options/global'
require 'emr/options/global_flag'
require 'emr/options/arg'
require 'emr/options/with_arg'
require 'emr/options/instance_count'
require 'emr/options/instance_type'
require 'emr/options/param'
require 'emr/options/flag'
require 'emr/options/args'

module Emr::CommandLoader
  def self.add_commands(commands, opts)

    commands.opts = opts

    step_commands = ["--jar", "--resize-jobflow", "--enable-debugging", "--hive-interactive",
                     "--pig-interactive", "--hive-script", "--pig-script", "--hive-site", "--script"]

    opts.separator "\n  Creating Job Flows\n"

    commands.parse_command(Emr::Commands::CreateJobFlow, "--create", "Create a new job flow")
    commands.parse_options(["--create"], [
      [ Emr::Options::WithArg, "--name NAME",                 "The name of the job flow being created", :jobflow_name ],
      [ Emr::Options::Flag,    "--alive",                     "Create a job flow that stays running even though it has executed all its steps", :alive ],
      [ Emr::Options::WithArg, "--with-termination-protection",   "Create a job with termination protection (default is no termination protection)", :with_termination_protection ],
      [ Emr::Options::WithArg, "--visible-to-all-users",   "Create a job other IAM users can perform API calls (default is false)", :visible_to_all_users],
      [ Emr::Options::WithArg, "--with-supported-products PRODUCTS",   "Add supported products", :with_supported_products ],
      [ Emr::Options::WithArg, "--num-instances NUM",         "Number of instances in the job flow", :instance_count ],
      [ Emr::Options::WithArg, "--slave-instance-type TYPE",  "The type of the slave instances to launch", :slave_instance_type ],
      [ Emr::Options::WithArg, "--master-instance-type TYPE", "The type of the master instance to launch", :master_instance_type ],
      [ Emr::Options::WithArg, "--ami-version VERSION",       "The version of ami to launch the job flow with", :ami_version ],
      [ Emr::Options::WithArg, "--key-pair KEY_PAIR",         "The name of your Amazon EC2 Keypair", :key_pair ],
      [ Emr::Options::WithArg, "--jobflow-role ROLE",         "Use specified EC2 role to start instances", :jobflow_role],
      [ Emr::Options::WithArg, "--availability-zone A_Z",     "Specify the Availability Zone in which to launch the job flow", :az ],
      [ Emr::Options::WithArg, "--info INFO",                 "Specify additional info to job flow creation", :ainfo ],
      [ Emr::Options::WithArg, "--hadoop-version VERSION",    "Specify the Hadoop Version to install", :hadoop_version ],
      [ Emr::Options::Flag,    "--plain-output",              "Return the job flow id from create step as simple text", :plain_output ],
      [ Emr::Options::WithArg, "--subnet EC2-SUBNET_ID",      "Specify the VPC subnet that you want to run in", :subnet_id ],
    ])

    commands.parse_command(Emr::Commands::CreateInstanceGroup, "--instance-group ROLE", "Specify an instance group while creating a jobflow")
    commands.parse_options(["--instance-group", "--add-instance-group"], [
      [Emr::Options::WithArg, "--bid-price PRICE",        "The bid price for this instance group", :bid_price]
    ])

    opts.separator "\n  Passing arguments to steps\n"

    commands.parse_options(step_commands + ["--bootstrap-action", "--stream", "--supported-product"], [
      [ Emr::Options::Args,    "--args ARGS",                 "A command separated list of arguments to pass to the step" ],
      [ Emr::Options::Arg,     "--arg ARG",                   "An argument to pass to the step" ],
      [ Emr::Options::WithArg, "--step-name STEP_NAME",       "Set name for the step", :step_name ],
      [ Emr::Options::WithArg, "--step-action STEP_ACTION",   "Action to take when step finishes. One of CANCEL_AND_WAIT, TERMINATE_JOB_FLOW or CONTINUE", :step_action ],
    ])

    opts.separator "\n  Specific Steps\n"

    commands.parse_command(Emr::Commands::ResizeJobflow, "--resize-jobflow",     "Add a step to resize the job flow")
    commands.parse_command(Emr::Commands::EnableDebugging, "--enable-debugging", "Enable job flow debugging (you must be signed up to SimpleDB for this to work)")
    commands.parse_command(Emr::Commands::WaitForSteps, "--wait-for-steps",     "Wait for all steps to reach a terminal state")
    commands.parse_command(Emr::Commands::Script, "--script SCRIPT_PATH",      "Add a step that runs a script in S3")

    opts.separator "\n  Adding Steps from a Json File to Job Flows\n"

    commands.parse_command(Emr::Commands::JsonStep, "--json FILE", "Add a sequence of steps stored in the json file FILE")
    commands.parse_options(["--json"], [
      [ Emr::Options::Param, "--param VARIABLE=VALUE ARGS", "Substitute the string VARIABLE with the string VALUE in the json file", :variables ],
    ])

    opts.separator "\n  Pig Steps\n"

    commands.parse_command(Emr::Commands::PigScript,      "--pig-script [SCRIPT]",
                           "Add a step that runs a Pig script")
    commands.parse_command(Emr::Commands::PigInteractive, "--pig-interactive",
                           "Add a step that sets up the job flow for an interactive (via SSH) pig session")
    commands.parse_options(["--pig-script", "--pig-interactive"], [
      [ Emr::Options::WithArg, "--pig-versions VERSIONS",
        "A comma separated list of Pig versions", :pig_versions ],
    ])


    opts.separator "\n  Hive Steps\n"

    commands.parse_command(Emr::Commands::HiveScript, "--hive-script [SCRIPT]",      "Add a step that runs a Hive script")
    commands.parse_command(Emr::Commands::HiveInteractive, "--hive-interactive", "Add a step that sets up the job flow for an interactive (via SSH) hive session")
    commands.parse_command(Emr::Commands::HiveSite, "--hive-site HIVE_SITE", "Override Hive configuration with configuration from HIVE_SITE")
    commands.parse_options(["--hive-script", "--hive-interactive", "--hive-site"], [
      [ Emr::Options::WithArg,     "--hive-versions VERSIONS", "A comma separated list of Hive versions", :hive_versions]
    ])

    opts.separator "\n  HBase Options\n"

    commands.parse_command(Emr::Commands::HbaseInstall,         "--hbase",                      "Install HBase on the cluster")
    commands.parse_command(Emr::Commands::HbaseBackup,          "--hbase-backup",               "Backup HBase to S3")
    commands.parse_command(Emr::Commands::HbaseRestore,         "--hbase-restore",              "Restore HBase from S3")
    commands.parse_command(Emr::Commands::HbaseBackupSchedule,  "--hbase-schedule-backup",      "Schedule regular backups to S3")

    commands.parse_options(["--hbase-backup", "--hbase-restore", "--hbase-schedule-backup"], [
      [ Emr::Options::WithArg, "--backup-dir DIRECTORY", "Location where backup is stored", :backup_dir]
    ])

    commands.parse_options(["--hbase-backup", "--hbase-schedule-backup"], [
      [ Emr::Options::Flag, "--consistent", "Perform a consistent backup (inconsistent is default)", :consistent]
    ])

    commands.parse_options(["--hbase-backup", "--hbase-restore"], [
      [ Emr::Options::WithArg, "--backup-version VERSION", "Backup version to restore", :backup_version ]
    ])

    commands.parse_options(["--hbase-schedule-backup"], [
      [ Emr::Options::WithArg, "--full-backup-time-interval  TIME_INTERVAL", "The time between full backups",                :full_backup_time_interval],
      [ Emr::Options::WithArg, "--full-backup-time-unit      TIME_UNIT",
                "time units for full backup's time-interval either minutes, hours or days",                          :full_backup_time_unit],
      [ Emr::Options::WithArg, "--start-time START_TIME",       "The time of the first backup",                              :start_time],
      [ Emr::Options::Flag, "--disable-full-backups",                     "Stop scheduled full backups from running",     :disable_full_backups],
      [ Emr::Options::WithArg, "--incremental-backup-time-interval TIME_INTERVAL", "The time between incremental backups",   :incremental_time_interval],
      [ Emr::Options::WithArg, "--incremental-backup-time-unit TIME_UNIT",
                "time units for incremental backup's time-interval either minutes, hours or days",                   :incremental_time_unit],
      [ Emr::Options::Flag, "--disable-incremental-backups",       "Stop scheduled incremental backups from running",     :disable_incremental_backups],
    ])

    opts.separator "\n  Adding Jar Steps to Job Flows\n"

    commands.parse_command(Emr::Commands::JarStep, "--jar JAR", "Run a Hadoop Jar in a step")
    commands.parse_options(["--jar"], [
      [ Emr::Options::Arg, "--main-class MAIN_CLASS",  "The main class of the jar", :main_class ]
    ])

    opts.separator "\n  Adding Streaming Steps to Job Flows\n"

    commands.parse_command(Emr::Commands::StreamStep, "--stream", "Add a step that performs hadoop streaming")
    commands.parse_options(["--stream"], [
      [ Emr::Options::WithArg, "--input INPUT",               "Input to the steps, e.g. s3n://mybucket/input", :input],
      [ Emr::Options::WithArg, "--output OUTPUT",             "The output to the steps, e.g. s3n://mybucket/output", :output],
      [ Emr::Options::WithArg, "--mapper MAPPER",             "The mapper program or class", :mapper],
      [ Emr::Options::WithArg, "--cache CACHE_FILE",          "A file to load into the cache, e.g. s3n://mybucket/sample.py#sample.py", :cache ],
      [ Emr::Options::WithArg, "--cache-archive CACHE_FILE",  "A file to unpack into the cache, e.g. s3n://mybucket/sample.jar", :cache_archive, ],
      [ Emr::Options::WithArg, "--jobconf KEY=VALUE",         "Specify jobconf arguments to pass to streaming, e.g. mapred.task.timeout=800000", :jobconf],
      [ Emr::Options::WithArg, "--reducer REDUCER",           "The reducer program or class", :reducer],
    ])

    opts.separator "\n  Adding and Modifying Instance Groups\n"

    commands.parse_command(Emr::Commands::ModifyInstanceGroup, "--modify-instance-group INSTANCE_GROUP", "Modify an existing instance group")
    commands.parse_command(Emr::Commands::AddInstanceGroup,    "--add-instance-group ROLE", "Add an instance group to an existing jobflow")
    commands.parse_command(Emr::Commands::UnarrestInstanceGroup, "--unarrest-instance-group ROLE", "Unarrest an instance group of the supplied jobflow")
    commands.parse_options(["--instance-group", "--modify-instance-group", "--add-instance-group", "--create"], [
     [ Emr::Options::InstanceCount, "--instance-count INSTANCE_COUNT", "Set the instance count of an instance group", :instance_count ]
    ])
    commands.parse_options(["--instance-group", "--add-instance-group", "--create"], [
     [ Emr::Options::InstanceType,  "--instance-type INSTANCE_TYPE", "Set the instance type of an instance group", :instance_type ],
    ])

    opts.separator "\n  Contacting the Master Node\n"

    commands.parse_command(Emr::Commands::Ssh, "--ssh [COMMAND]", "SSH to the master node and optionally run a command")
    commands.parse_command(Emr::Commands::Put, "--put SRC", "Copy a file to the job flow using scp")
    commands.parse_command(Emr::Commands::Get, "--get SRC", "Copy a file from the job flow using scp")
    commands.parse_command(Emr::Commands::Put, "--scp SRC", "Copy a file to the job flow using scp")
    commands.parse_options(["--get", "--put", "--scp"], [
      [ Emr::Options::WithArg, "--to DEST",    "Destination location when copying files", :dest ],
    ])
    commands.parse_command(Emr::Commands::Socks, "--socks", "Start a socks proxy tunnel to the master node")

    commands.parse_command(Emr::Commands::Logs, "--logs", "Display the step logs for the last executed step")

    opts.separator "\n  Assigning Elastic IP to Master Node\n"

    commands.parse_command(Emr::Commands::Eip, "--eip [ElasticIP]", "Associate ElasticIP to master node. If no ElasticIP is specified, allocate and associate a new one.")

    opts.separator "\n  Settings common to all step types\n"

    commands.parse_options(["--ssh", "--scp", "--eip"], [
      [ Emr::Options::Flag,   "--no-wait",    "Don't wait for the Master node to start before executing scp or ssh or assigning EIP", :no_wait ],
      [ Emr::Options::Global, "--key-pair-file FILE_PATH",   "Path to your local pem file for your EC2 key pair", :key_pair_file ],
    ])

    opts.separator "\n  Specifying Supported Products\n"
    commands.parse_command(Emr::Commands::SupportedProduct, "--supported-product NAME", "Install a supported product")

    opts.separator "\n  Specifying Bootstrap Actions\n"
    commands.parse_command(Emr::Commands::BootstrapAction, "--bootstrap-action SCRIPT", "Run a bootstrap action script on all instances")
    commands.parse_options(["--bootstrap-action"], [
      [ Emr::Options::WithArg, "--bootstrap-name NAME",    "Set the name of the bootstrap action", :bootstrap_name ],
    ])


    opts.separator "\n  Listing and Describing Job flows\n"
    commands.parse_command(Emr::Commands::ListAction, "--list", "List all job flows created in the last 2 days")
    commands.parse_command(Emr::Commands::DescribeAction, "--describe", "Dump a JSON description of the supplied job flows")
    commands.parse_command(Emr::Commands::PrintHiveVersion, "--print-hive-version", "Prints the version of Hive that's currently active on the job flow")
    commands.parse_options(["--lisEmr::Options::t", "--describe"], [
      [ Emr::Options::WithArg, "--state NAME",   "List all job flows in a given state (STARTING, RUNNING, etc.)", :state ],
      [ Emr::Options::Flag,    "--active",       "List running, starting or shutting down job flows", :active ],
      [ Emr::Options::Flag,    "--all",          "List all job flows in the last 2 weeks", :all ],
      [ Emr::Options::WithArg,    "--created-after=DATETIME", "List all jobflows created after DATETIME (xml date time format)", :created_after],
      [ Emr::Options::WithArg,    "--created-before=DATETIME", "List all jobflows created before DATETIME (xml date time format)", :created_before],
      [ Emr::Options::Flag,    "--no-steps",     "Do not list steps when listing jobs", :no_steps ],
    ])

    opts.separator "\n  Terminating Job Flows\n"

    commands.parse_command(Emr::Commands::SetTerminationProtection, "--set-termination-protection BOOL", "Enable or disable job flow termination protection. Either true or false")

    commands.parse_command(Emr::Commands::SetVisibleToAllUsers, "--set-visible-to-all-users BOOL", "Enable or disable job flow visible to other IAM users. Either true or false")

    commands.parse_command(Emr::Commands::TerminateAction, "--terminate", "Terminate job flows")

    opts.separator "\n  Common Options\n"

    commands.parse_options(["--jobflow", "--describe"], [
      [ Emr::Options::Global, "--jobflow JOB_FLOW_ID",  "The job flow to act on", :jobflow, /^j-[A-Z0-9]+$/],
    ])

    commands.parse_options(:global, [
      [ Emr::Options::GlobalFlag, "--verbose",  "Turn on verbose logging of program interaction", :verbose ],
      [ Emr::Options::GlobalFlag, "--trace",    "Trace commands made to the webservice", :trace ],
      [ Emr::Options::Global, "--credentials CRED_FILE",  "File containing access-id and private-key", :credentials],
      [ Emr::Options::Global, "--access-id ACCESS_ID",  "AWS Access Id", :aws_access_id],
      [ Emr::Options::Global, "--private-key PRIVATE_KEY",  "AWS Private Key", :aws_secret_key],
      [ Emr::Options::Global, "--log-uri LOG_URI",  "Location in S3 to store logs from the job flow, e.g. s3n://mybucket/logs", :log_uri ],
    ])
    commands.parse_command(Emr::Commands::Version, "--version", "Print version string")
    commands.parse_command(Emr::Commands::Help, "--help", "Show help message")

    opts.separator "\n  Uncommon Options\n"

    commands.parse_options(:global, [
      [ Emr::Options::GlobalFlag, "--debug",  "Print stack traces when exceptions occur", :debug],
      [ Emr::Options::Global,     "--endpoint ENDPOINT",  "EMR web service host to connect to", :endpoint],
      [ Emr::Options::Global,     "--region REGION",  "The region to use for the endpoint", :region],
      [ Emr::Options::Global,     "--apps-path APPS_PATH",  "Specify s3:// path to the base of the emr public bucket to use. e.g s3://us-east-1.elasticmapreduce", :apps_path],
      [ Emr::Options::Global,     "--beta-path BETA_PATH",  "Specify s3:// path to the base of the emr public bucket to use for beta apps. e.g s3://beta.elasticmapreduce", :beta_path],
    ])

    opts.separator "\n  Short Options\n"
    commands.parse_command(Emr::Commands::Help, "-h", "Show help message")
    commands.parse_options(:global, [
      [ Emr::Options::GlobalFlag, "-v", "Turn on verbose logging of program interaction", :verbose ],
      [ Emr::Options::Global, "-c CRED_FILE",  "File containing access-id and private-key", :credentials ],
      [ Emr::Options::Global, "-a ACCESS_ID",  "AWS Access Id", :aws_access_id],
      [ Emr::Options::Global, "-p PRIVATE_KEY",  "AWS Private Key", :aws_secret_key],
      [ Emr::Options::Global, "-j JOB_FLOW_ID",  "The job flow to act on", :jobflow, /^j-[A-Z0-9]+$/],
    ])

  end

  def self.is_step_command(cmd)
    return cmd.respond_to?(:steps)
  end

  def self.is_ba_command(cmd)
    return cmd.respond_to?(:bootstrap_actions)
  end

  def self.is_create_child_command(cmd)
    return is_step_command(cmd) ||
      is_ba_command(cmd) ||
      cmd.is_a?(Emr::Commands::AddInstanceGroup) ||
      cmd.is_a?(Emr::Commands::SupportedProduct) ||
      cmd.is_a?(Emr::Commands::CreateInstanceGroup)
  end

  # this function pull out steps if there is a create command that preceeds them
  def self.fold_commands(commands)
    last_create_command = nil
    new_commands = []
    for cmd in commands do
      if cmd.is_a?(Emr::Commands::CreateJobFlow) then
        last_create_command = cmd
      elsif is_create_child_command(cmd) then
        if last_create_command == nil then
          if is_step_command(cmd) then
            last_create_command = Emr::Commands::AddJobFlowSteps.new(
              "--add-steps", "Add job flow steps", nil, commands
            )
            new_commands << last_create_command
          elsif is_ba_command(cmd) then
            raise RuntimeError, "the option #{cmd.name} must come after the --create option"
          elsif cmd.is_a?(Emr::Commands::CreateInstanceGroup) then
            raise RuntimeError, "the option #{cmd.name} must come after the --create option"
          elsif cmd.is_a?(Emr::Commands::SupportedProduct) then
            raise RuntimeError, "the option #{cmd.name} must come after the --create option"
          elsif cmd.is_a?(Emr::Commands::AddInstanceGroup) then
            new_commands << cmd
            next
          else
            next
          end
        end

        actioned = false
        if is_step_command(cmd) then
          if ! last_create_command.respond_to?(:add_step_command) then
            last_create_command = Emr::Commands::AddJobFlowSteps.new(
              "--add-steps", "Add job flow steps", nil, commands
            )
          end
          last_create_command.add_step_command(cmd)
          actioned = true
        end
        if is_ba_command(cmd) then
          if ! last_create_command.respond_to?(:add_bootstrap_command) then
            raise RuntimeError, "Bootstrap actions must follow a --create command"
          end
          last_create_command.add_bootstrap_command(cmd)
          actioned = true
        end
        if cmd.is_a?(Emr::Commands::SupportedProduct) then
          last_create_command.add_supported_product_command(cmd)
          actioned = true
        end
        if cmd.is_a?(Emr::Commands::CreateInstanceGroup) || cmd.is_a?(Emr::Commands::AddInstanceGroup) then
          if last_create_command.respond_to?(:add_instance_group_command) then
            last_create_command.add_instance_group_command(cmd)
          else
            new_commands << cmd
          end
          actioned = true
        end

        if ! actioned then
          raise RuntimeError, "Unknown child command #{cmd.name} following #{last_create_command.name}"
        end
        next
      end
      new_commands << cmd
    end

    commands.commands = new_commands
  end

  def self.create_and_execute_commands(args, client_class, logger, executor, exit_on_error=true)
    commands = Emr::CommandsList.new(logger, executor)

    begin
      opts = OptionParser.new do |opts|
        add_commands(commands, opts)
      end
      opts.parse!(args)

      if commands.get_field(:trace) then
        logger.level = :trace
      end

      commands.parse_jobflows(args)

      if commands.commands.size == 0 then
        commands.commands << Emr::Commands::Help.new("--help", "Print help text", nil, commands)
      end

      credentials = Emr::Credentials.new(commands)
      credentials.parse_credentials(commands.get_field(:credentials, "credentials.json"),
                                    commands.global_options)

      work_out_globals(commands)
      fold_commands(commands)
      commands.validate
      client = Emr::Client.new(commands, logger, client_class)
      commands.enact(client)
    rescue RuntimeError => e
      logger.puts("Error: " + e.message)
      if commands.get_field(:trace) then
        logger.puts(e.backtrace.join("\n"))
      end
      if exit_on_error then
        exit(-1)
      else
        raise e
      end
    end
    return commands
  end

  def self.work_out_globals(commands)
    options = commands.global_options
    if commands.have(:region) then
      if commands.have(:endpoint) then
        raise RuntimeError, "You may not specify --region together with --endpoint"
      end

      endpoint = "https://#{options[:region]}.elasticmapreduce.amazonaws.com"
      commands.global_options[:endpoint] = endpoint
    end

    if commands.have(:endpoint) then
      region_match = commands.get_field(:endpoint).match("^https*://(.*)\.elasticmapreduce")
      if ! commands.have(:apps_path) && region_match != nil then
        options[:apps_path] = "s3://#{region_match[1]}.elasticmapreduce"
      end
    end

    options[:apps_path] ||= "s3://us-east-1.elasticmapreduce"
    options[:beta_path] ||= "s3://beta.elasticmapreduce"
    for key in [:apps_path, :beta_path] do
      options[key].chomp!("/")
    end
  end
end
