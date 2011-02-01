require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  test "should get index" do
    request.env['REMOTE_USER'] = 'ptolemy'
    get :index
    assert_response :success
    assert_select 'a[href=?]', directory_user_path('ptolemy')
    assert_select 'a[href=?]', directory_user_path('alidrisi')
  end
  
  test "should get own page as admin" do
    request.env['REMOTE_USER'] = 'ptolemy'
    get :show, :id => 'ptolemy'
    assert_response :success
    assert_select 'h1', 'Claudius Ptolemy'
    assert_select 'a[href=?]', edit_directory_user_mail_path('ptolemy')
    assert_select 'a[href=?]', edit_directory_user_password_path('ptolemy')
    assert_select 'li', /1 group/
    assert_select 'a[href=?]', edit_directory_user_memberships_path('ptolemy')
    assert_select 'a[href=?]', directory_group_path('admins')
  end
  
  test "should get own page" do
    request.env['REMOTE_USER'] = 'alidrisi'
    get :show, :id => 'alidrisi'
    assert_response :success
    assert_select 'h1', 'Abu Abd Allah Muhammad al-Idrisi'
    assert_select 'a[href=?]', edit_directory_user_mail_path('alidrisi')
    assert_select 'a[href=?]', edit_directory_user_password_path('alidrisi')
    assert_select 'li', /0 groups/
  end
  
  test "should get another user page as admin" do
    request.env['REMOTE_USER'] = 'ptolemy'
    get :show, :id => 'alidrisi'
    assert_response :success
    assert_select 'h1', 'Abu Abd Allah Muhammad al-Idrisi'
    assert_select 'a[href=?]', edit_directory_user_mail_path('alidrisi')
    assert_select 'a[href=?]', edit_directory_user_password_path('alidrisi')
    assert_select 'li', /0 groups/
    assert_select 'a[href=?]', edit_directory_user_memberships_path('alidrisi')
  end
  
  test "should get another user page" do
    request.env['REMOTE_USER'] = 'alidrisi'
    get :show, :id => 'ptolemy'
    assert_response :success
    assert_select 'h1', 'Claudius Ptolemy'
    assert_select 'li', /1 group/
    assert_select 'a[href=?]', directory_group_path('admins')
  end
  
end
