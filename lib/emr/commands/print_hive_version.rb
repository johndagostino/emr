require 'emr/commands/abstract_ssh'

class Emr::Commands::PrintHiveVersion < Emr::Commands::AbstractSsh
    def enact(client)
        super(client)
        stdin, stdout, stderr = Open3.popen3("ssh -i #{key_pair_file} hadoop@#{hostname} '/home/hadoop/bin/hive -version'")
        version = stdout.readlines.join
        err = stderr.readlines.join
        if version.length > 0
            puts version
            elsif err =~ /Unrecognised option/ or err =~ /Error while determing Hive version/
            stdin, stdout, stderr = Open3.popen3("ssh -i #{key_pair_file} hadoop@#{hostname} 'ls -l /home/hadoop/bin/hive'")
            version = stdout.readlines.join
            version =~ /hive-(.*)\/bin\/hive/
            puts "Hive version " + $1
            else
            puts "Unable to determine Hive version"
        end
    end
end