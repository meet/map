require 'test_helper'

class LoginFlowsTest < ActionController::IntegrationTest
  
  test "should be able to log in" do
    open_session do |s|
      s.extend(OpenIdAuthorization::MockOpenIdFetcher::Session)
      s.https!
      s.login '/', 'ptolemy', ''
      s.assert_redirected_to '/'
      s.get '/'
      s.assert_response :success
      s.assert_template :index
    end
  end
  
end
