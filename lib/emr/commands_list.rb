class Emr::CommandsList
  attr_accessor :opts, :global_options, :commands, :logger, :executor

  def initialize(logger, executor)
    @commands = []
    @opts = nil
    @global_options = {
      :jobflow => []
    }
    @logger = logger
    @executor = executor
  end

  def last
    @commands.last
  end

  def <<(value)
    @commands << value
  end

  def size
    @commands.size
  end

  def validate
    @commands.each { |x| x.validate }
  end

  def enact(client)
    @commands.each { |x| x.enact(client) }
  end

  def each(&block)
    @commands.each(&block)
  end

  def parse_command(klass, name, description)
    @opts.on(name, description) do |arg|
      self << klass.new(name, description, arg, self)
    end
  end

  def parse_option(klass, name, description, parent_commands, *args)
    @opts.on(name, description) do |arg|
      klass.new(name, description, arg, parent_commands, self, *args).attach(commands)
    end
  end

  def parse_options(parent_commands, options)
    for option in options do
      klass, name, description = option[0..2]
      args = option[3..-1]
      self.parse_option(klass, name, description, parent_commands, *args)
    end
  end

  def parse_jobflows(args)
    for arg in args do
      if arg =~ /^j-\w{5,20}$/  then
        @global_options[:jobflow] << arg
      end
    end
  end

  def have(field_symbol)
    return @global_options[field_symbol] != nil
  end

  def get_field(field_symbol, default_value=nil)
    value = @global_options[field_symbol]
    if ( value == nil ) then
      return default_value
    else
      return value
    end
  end

  def exec(cmd)
    @executor.exec(cmd)
  end
end

