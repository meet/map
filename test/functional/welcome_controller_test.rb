require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  
  test "should require login" do
    get :index
    assert_response :unauthorized
  end
  
end
