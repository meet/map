ENV["RAILS_ENV"] = "test"
require 'directory/test_help'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  
  def setup
    Directory.connection.mock_user(:uid => 'ptolemy', :givenname => 'Claudius', :sn => 'Ptolemy')
    Directory.connection.mock_user(:uid => 'alidrisi', :givenname => 'Abu Abd Allah Muhammad', :sn => 'al-Idrisi')
    Directory.connection.mock_group(:cn => 'admins',
                                    :description => 'Administrators',
                                    :memberuid => [ 'ptolemy' ])
  end
  
  def teardown
    Directory.connection.clear_mocks
    Directory.connection.clear_changes
    ActionMailer::Base.deliveries.clear
  end
  
end
