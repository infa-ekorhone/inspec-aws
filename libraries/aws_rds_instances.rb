# frozen_string_literal: true
# Extends the built-in functionality of Inspec-AWS to suit Informatica Compliance needs
require 'aws_backend'

class AwsRdsInstances < AwsResourceBase
  name 'aws_rds_instances'
  desc 'Verifies settings for AWS RDS Instances in bulk'

  example '
    describe aws_rds_instances do
      it { should exist }
    end
  '

  attr_reader :table

  FilterTable.create
             .register_column(:db_instance_identifiers, field: :db_instance_identifier)
             .register_column(:endpoints,    field: :endpoint)
             .install_filter_methods_on_resource(self, :table)
             #TODO: Add more tables and values

  def initialize(opts = {})
    super(opts)
    validate_parameters
    @table = fetch_data
  end

  def fetch_data
    db_instance_rows = []
    catch_aws_errors do
      @db_instances = @aws.rds_client.describe_db_instances.to_h[:db_instances]
    end
    return [] if !@db_instances || @db_instances.empty?
    @db_instances.each do |db_instance|
      db_instance_rows += [{ db_instance_identifier: db_instance[:db_instance_identifier],
                        endpoint: db_instance[:endpoint] }]
    end
    @table = db_instance_rows
  end
end
