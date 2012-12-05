require 'test_helper'

class PasswordsControllerTest < ActionController::TestCase
  
  test "should get edit page for admin" do
    request.session[:username] = 'ptolemy'
    get :edit, :directory_user_id => 'ptolemy'
    assert_response :success
    assert_template :edit
  end
  
  test "should get edit page" do
    request.session[:username] = 'alidrisi'
    get :edit, :directory_user_id => 'alidrisi'
    assert_response :success
    assert_template :edit
  end
  
  test "should get reset page" do
    request.session[:username] = 'ptolemy'
    get :edit, :directory_user_id => 'alidrisi'
    assert_response :success
    assert_template :reset
  end
  
  test "edit should be denied" do
    request.session[:username] = 'alidrisi'
    get :edit, :directory_user_id => 'ptolemy'
    assert_response :forbidden
  end
  
  test "should reset password" do
    request.session[:username] = 'ptolemy'
    post :create, :directory_user_id => 'alidrisi'
    assert_redirected_to directory_user_path('alidrisi')
    
    alidrisi = Directory::User.find('alidrisi')
    assert ! alidrisi.enabled
    assert_equal 2, Directory.connection.changes.size
    assert_equal :shadowexpire, Directory.connection.changes.first.attribute
    assert_equal :userpassword, Directory.connection.changes.second.attribute
    
    note = ActionMailer::Base.deliveries.first
    assert note.to.include? Directory::User.find('alidrisi').mail
    assert_match /temporary password/i, note.body
    assert_match directory_user_path('alidrisi'), note.body
    assert_match /Ptolemy/, note.body
  end
  
  test "reset should be denied" do
    request.session[:username] = 'alidrisi'
    post :create, :directory_user_id => 'ptolemy'
    assert_response :forbidden
    
    alidrisi = Directory::User.find('alidrisi')
    assert alidrisi.enabled
    assert Directory.connection.changes.empty?
    
    assert ActionMailer::Base.deliveries.empty?
  end
  
  test "update should fail with missing password" do
    Directory.connection.mock_bind('alidrisi', 'Andalus123')
    request.session[:username] = 'alidrisi'
    put :update, :directory_user_id => 'alidrisi', :password => {
      :new_password => 'Sicily123', :new_password_confirmation => 'Sicily123' }
    assert_response :success
    assert_template :edit
    assert_equal ['incorrect'], assigns(:password).errors[:current_password]
    
    assert Directory.connection.changes.empty?
  end
  
  test "update should fail with incorrect password" do
    Directory.connection.mock_bind('alidrisi', 'Andalus123')
    request.session[:username] = 'alidrisi'
    put :update, :directory_user_id => 'alidrisi', :password => {
      :current_password => 'Italy123', :new_password => 'Sicily123', :new_password_confirmation => 'Sicily123' }
    assert_response :success
    assert_template :edit
    assert_equal ['incorrect'], assigns(:password).errors[:current_password]
    
    assert Directory.connection.changes.empty?
  end
  
  test "update should fail with unacceptable password" do
    Directory.connection.mock_bind('alidrisi', 'Andalus123')
    request.session[:username] = 'alidrisi'
    put :update, :directory_user_id => 'alidrisi', :password => {
      :current_password => 'Andalus123', :new_password => 'a', :new_password_confirmation => 'a' }
    assert_response :success
    assert_template :edit
    assert ! assigns(:password).errors[:new_password].empty?
    
    assert Directory.connection.changes.empty?
  end
  
  test "should set password" do
    request.session[:username] = 'ptolemy'
    put :update, :directory_user_id => 'ptolemy', :password => {
      :new_password => 'Egypt123', :new_password_confirmation => 'Egypt123' }
    assert_redirected_to directory_user_path('ptolemy')
    
    assert Directory::User.find('ptolemy').enabled
    assert_equal 2, Directory.connection.changes.size
    assert_equal :shadowexpire, Directory.connection.changes.first.attribute
    assert_equal :userpassword, Directory.connection.changes.second.attribute
  end
  
  test "should update password" do
    Directory.connection.mock_bind('alidrisi', 'Andalus123')
    request.session[:username] = 'alidrisi'
    put :update, :directory_user_id => 'alidrisi', :password => {
      :current_password => 'Andalus123', :new_password => 'Sicily123', :new_password_confirmation => 'Sicily123' }
    assert_redirected_to directory_user_path('alidrisi')
    
    assert Directory::User.find('alidrisi').enabled
    assert_equal 2, Directory.connection.changes.size
    assert_equal :shadowexpire, Directory.connection.changes.first.attribute
    assert_equal :userpassword, Directory.connection.changes.second.attribute
  end
  
  test "should update password on Google Apps" do
    Directory.connection.mock_bind('alidrisi', 'Andalus123')
    GoogleApps.connection.mock_entry('alidrisi', GoogleApps::User.new(:user_name => 'alidrisi'))
    
    request.session[:username] = 'alidrisi'
    put :update, :directory_user_id => 'alidrisi', :password => {
      :current_password => 'Andalus123', :new_password => 'Sicily123', :new_password_confirmation => 'Sicily123' }
    assert_redirected_to directory_user_path('alidrisi')
    
    assert_equal :shadowexpire, Directory.connection.changes.first.attribute
    assert_equal :userpassword, Directory.connection.changes.second.attribute
    
    assert_equal 1, GoogleApps.connection.changes.size
    assert_equal :POST, GoogleApps.connection.changes.first.first
    assert_match /#{Digest::SHA1.hexdigest('Sicily123')}/, GoogleApps.connection.changes.first.third
  end
  
end
