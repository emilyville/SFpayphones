# Load the rails application
require File.expand_path('../application', __FILE__)

Rails.logger = Logger.new(STDOUT)
Resque.logger = Logger.new(STDOUT)
# Initialize the rails application
Payphones::Application.initialize!