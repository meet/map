require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  
  test "should get index" do
    request.session[:username] = 'ptolemy'
    get :index
    assert_response :success
  end
  
  test "should get group page" do
    request.session[:username] = 'ptolemy'
    get :show, :id => 'admins'
    assert_response :success
    assert_select 'h1', 'Administrators'
    assert_select 'a[href=?]', directory_user_path('ptolemy')
  end
  
end
