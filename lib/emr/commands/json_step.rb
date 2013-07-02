require 'emr/commands/step'

class Emr::Commands::JsonStep < Emr::Commands::Step
  attr_accessor :variables

  def initialize(*args)
      super(*args)
      @variables = []
  end

  def steps
   content = steps = nil
   filename = get_field(:arg)
   begin
       content = File.read(filename)
       rescue Exception => e
       raise RuntimeError, "Couldn't read json file #{filename}"
   end
   for var in get_field(:variables, []) do
       content.gsub!(var[:key], var[:value])
   end
       begin
           steps = JSON.parse(content)
           rescue Exception => e
           raise RuntimeError, "Error parsing json from file #{filename}"
       end
       if steps.is_a?(Array) then
           return steps
           else
           return [ steps ]
       end
  end
end