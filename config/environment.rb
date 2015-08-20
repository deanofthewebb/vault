# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Adding to prevent failure during Chef run
ENV['HOME'] = '/root'

# Initialize the Rails application.
Rails.application.initialize!
