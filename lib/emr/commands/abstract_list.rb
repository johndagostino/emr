require 'emr/commands'
require 'emr/command'

class Emr::Commands::AbstractList < Emr::Command
  attr_accessor :state, :max_results, :active, :all, :no_steps, :created_after, :created_before

  def enact(client)
    options = {}
    states = []
    if get_field(:jobflow, []).size > 0 then
      options = { 'JobFlowIds' => get_field(:jobflow) }
      else
      if get_field(:active) then
        states = %w(RUNNING SHUTTING_DOWN STARTING WAITING BOOTSTRAPPING)
      end
      if get_field(:state) then
        states << get_field(:state)
      end

      if get_field(:all) then
        options = { 'CreatedAfter' => (Time.now - (58 * 24 * 3600)).xmlschema }
        else
        options = {}
        options['CreatedAfter']  = get_field(:created_after) if get_field(:created_after)
        options['CreatedBefore'] = get_field(:created_before) if get_field(:created_before)
        options['JobFlowStates'] = states if states.size > 0
      end
    end
    result = client.describe_jobflow(options)
    # add the described jobflow to the supplied jobflows
    commands.global_options[:jobflow] += result['JobFlows'].map { |x| x['JobFlowId'] }
    commands.global_options[:jobflow].uniq!

    return result
  end
end
