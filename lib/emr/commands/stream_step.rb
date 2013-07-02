require 'emr/commands/step'

class Emr::Commands::StreamStep < Emr::Commands::Step
  attr_accessor :input, :output, :mapper, :cache, :cache_archive, :jobconf, :reducer, :args

  GENERIC_OPTIONS = Set.new(%w(-conf -D -fs -jt -files -libjars -archives))

  def initialize(*args)
      super(*args)
      @jobconf = []
  end

  def steps
    if get_field(:input) == nil ||
        get_field(:output) == nil ||
        get_field(:mapper) == nil ||
        get_field(:reducer) == nil then
        raise RuntimeError, "Missing arguments for --stream option"
    end

    timestr = Time.now.strftime("%Y-%m-%dT%H%M%S")
    stream_options = []
    for ca in get_field(:cache, []) do
        stream_options << "-cacheFile" << ca
    end

    for ca in get_field(:cache_archive, []) do
        stream_options << "-cacheArchive" << ca
    end

        for jc in get_field(:jobconf, []) do
            stream_options << "-jobconf" << jc
        end

    # Note that the streaming options should go before command options for
    # Hadoop 0.20
    step = {
          "Name"            => get_field(:step_name, "Example Streaming Step"),
          "ActionOnFailure" => get_field(:step_action, "CANCEL_AND_WAIT"),
          "HadoopJarStep"   => {
              "Jar" => "/home/hadoop/contrib/streaming/hadoop-streaming.jar",
              "Args" => (sort_streaming_args(get_field(:args))) + (stream_options) + [
              "-input",     get_field(:input),
              "-output",    get_field(:output),
              "-mapper",    get_field(:mapper),
              "-reducer",   get_field(:reducer)
              ]
          }
    }
    return [ step ]
  end

  def sort_streaming_args(streaming_args)
    sorted_streaming_args = []
    i=0
    while streaming_args && i < streaming_args.length
        if GENERIC_OPTIONS.include?(streaming_args[i]) then
            if i+1 < streaming_args.length
                sorted_streaming_args.unshift(streaming_args[i+1])
                sorted_streaming_args.unshift(streaming_args[i])
                i=i+2
                else
                raise RuntimeError, "Missing value for argument #{streaming_args[i]}"
            end
            else
            sorted_streaming_args << streaming_args[i]
            i=i+1
        end
    end

    sorted_streaming_args
  end
end
