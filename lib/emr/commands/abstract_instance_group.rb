require 'emr/command'

class Emr::Commands::AbstractInstanceGroup < Emr::Command
  attr_accessor :instance_group_id, :instance_type, :instance_role,
  :instance_count, :instance_group_name, :bid_price

  def initialize(*args)
    super(*args)
    if @arg =~ /^ig-/ then
      @instance_group_id = @arg
      else
      @instance_role = @arg.upcase
    end
  end

  def default_instance_group_name
    get_field(:instance_role).downcase.capitalize + " Instance Group"
  end

  def instance_group
    ig =  {
      "Name" => get_field(:instance_group_name),
      "InstanceRole" => get_field(:instance_role),
      "InstanceCount" => get_field(:instance_count),
      "InstanceType"  => get_field(:instance_type)
    }
    if get_field(:bid_price, nil) != nil
      if is_govcloud?
        raise RuntimeError, "SPOT instances (--bid-price) are not supported in GovCloud."
      end

      ig["BidPrice"] = get_field(:bid_price)
      ig["Market"] = "SPOT"
      else
      ig["Market"] = "ON_DEMAND"
    end
    return ig
  end

  def require_singleton_array(arr, msg)
    if arr.size != 1 then
      raise RuntimeError, "Expected to find one " + msg + " but found #{arr.size}."
    end
  end
end
