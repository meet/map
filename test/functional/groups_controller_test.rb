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
    assert_select 'td a[href=?]', directory_user_path('ptolemy')
  end
  
  test "should show group and email members" do
    request.session[:username] = 'ptolemy'
    get :show, :id => 'cartographers'
    assert_response :success
    assert_select 'h1', 'Cartographers'
    assert_select 'td a[href=?]', directory_group_path('admins')
    assert_select 'td', 'admins@ancient.carto'
  end
  
end
