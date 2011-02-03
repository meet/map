require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  
  test "should log out" do
    request.session[:username] = 'ptolemy'
    get :logout
    assert_response :success
    assert session.empty?
  end
  
end
