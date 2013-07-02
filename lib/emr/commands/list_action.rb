require 'emr/commands/abstract_list'

class Emr::Commands::ListAction < Emr::Commands::AbstractList

  def format(map, *fields)
    result = []
    for field in fields do
      key = field[0].split(".")
      value = map
      while key.size > 0 do
        value = value[key.first]
        key.shift
      end
        result << sprintf("%-#{field[1]}s", value)
    end
    result.join("")
  end

 def enact(client)
   result = super(client)
   job_flows = result['JobFlows']
   count = 0
   for job_flow in job_flows do
     if get_field(:max_results) && (count += 1) > get_field(:max_results) then
       break
     end
     logger.puts format(job_flow, ['JobFlowId', 20], ['ExecutionStatusDetail.State', 15],
                ['Instances.MasterPublicDnsName', 50]) + job_flow['Name']
     if ! get_field(:no_steps) then
       for step in job_flow['Steps'] do
         logger.puts "   " + format(step, ['ExecutionStatusDetail.State', 15], ['StepConfig.Name', 30])
       end
     end
   end
 end
end
