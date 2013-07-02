require 'emr/command'

class Emr::Commands::SupportedProduct < Emr::Command
  attr_accessor :name, :args

  def initialize(*args)
    super(*args)
    @args = []
  end

  def supported_product()
    product = {
      "Name" => @arg,
      "Args" => @args
    }
    return product
  end
end
