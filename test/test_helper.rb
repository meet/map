ENV["RAILS_ENV"] = "test"
require 'directory/test_help'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  
  def setup
    Directory.connect_with :base => 'dc=example,dc=com'
    Directory.connect_with :auth => nil
    Directory.connection.mock_user(:uid => 'ptolemy', :givenname => 'Claudius', :sn => 'Ptolemy')
    Directory.connection.mock_user(:uid => 'alidrisi', :givenname => 'Abu Abd Allah Muhammad', :sn => 'al-Idrisi')
    Directory.connection.mock_group(:cn => 'admins',
                                    :description => 'Administrators',
                                    :memberuid => [ 'ptolemy' ])
    Directory.connection.mock_group(:cn => 'cartographers',
                                    :description => 'Cartographers',
                                    :memberuid => [ 'admins@example.com', 'admins@ancient.carto' ] )
  end
  
  def teardown
    Directory.connection.clear_mocks
    Directory.connection.clear_changes
    GoogleApps.connection.clear_mocks
    GoogleApps.connection.clear_changes
    ActionMailer::Base.deliveries.clear
  end
  
end
