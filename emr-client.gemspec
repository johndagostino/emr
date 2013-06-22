$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "emr/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "EMR Client"
  s.version     = Emr::VERSION
  s.authors     = ["John D'Agostino"]
  s.email       = ["john.dagostino@fairfaxmedia.com.au"]
  s.homepage    = "https://github.com/johndagostino/emr"
  s.summary     = "Fork of Amazon Elatic MapReduce Client"
  s.description = "Fork of Amazon Elatic MapReduce Client"

  s.files = Dir["{lib}/**/*"] + ["LICENSE.txt", "Rakefile", "README"]
  s.bindir = 'bin'
  s.executables << 'elastic-mapreduce'
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'uuidtools'
  s.add_dependency 'rake'
  s.add_dependency 'aws-sdk'
end
