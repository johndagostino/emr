#
# Copyright 2008-2010 Amazon.com, Inc. or its affiliates.  All Rights Reserved.

require 'set'
require 'optparse'
require 'open3'
require 'aws/iam'

require 'emr/ec2_roles'
require 'emr/client'
require 'emr/ec2_client_wrapper'
require 'emr/credentials'

module Emr::Commands
  ELASTIC_MAPREDUCE_CLIENT_VERSION = "2013-03-19"
end

