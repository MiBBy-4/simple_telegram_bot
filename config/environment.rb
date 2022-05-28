# Load the Rails application.
require_relative "application"

database_connection_file = File.join(Rails.root, 'database_connection.env')
api_token = File.join(Rails.root, 'api_token.env')
load(database_connection_file) if File.exist?(database_connection_file)
load(api_token) if File.exist?(api_token)
# Initialize the Rails application.
Rails.application.initialize!
