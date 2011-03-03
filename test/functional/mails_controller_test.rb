require 'test_helper'

class MailsControllerTest < ActionController::TestCase
  
  test "should get edit page for admin self" do
    request.session[:username] = 'ptolemy'
    get :edit, :directory_user_id => 'ptolemy'
    assert_response :success
    assert_template :edit
  end
  
  test "should get edit page self" do
    request.session[:username] = 'alidrisi'
    get :edit, :directory_user_id => 'alidrisi'
    assert_response :success
    assert_template :edit
  end
  
  test "should get edit page for admin" do
    request.session[:username] = 'ptolemy'
    get :edit, :directory_user_id => 'alidrisi'
    assert_response :success
    assert_template :edit
  end
  
  test "edit should be denied" do
    request.session[:username] = 'alidrisi'
    get :edit, :directory_user_id => 'ptolemy'
    assert_response :forbidden
  end
  
  test "should update mail by admin" do
    request.session[:username] = 'ptolemy'
    put :update, :directory_user_id => 'alidrisi', :mail_forward => { :mail => 'example@example.com' }
    assert_redirected_to directory_user_path('alidrisi')
    
    alidrisi = Directory::User.find('alidrisi')
    assert_equal 'example@example.com', alidrisi.mail_forward
    change = Directory::MockLDAP::Change.new(alidrisi.dn, :mail, [ 'example@example.com' ])
    assert_equal [ change ], Directory.connection.changes
    
    note = ActionMailer::Base.deliveries.first
    assert note.to.include? alidrisi.mail
    assert_match /example@example.com/, note.body
    assert_match /Ptolemy/, note.body
  end
  
  test "update should be denied" do
    request.session[:username] = 'alidrisi'
    put :update, :directory_user_id => 'ptolemy', :mail_forward => { :mail => 'example@example.com' }
    assert_response :forbidden
    
    ptolemy = Directory::User.find('ptolemy')
    assert_equal nil, ptolemy.mail_forward
    assert Directory.connection.changes.empty?
    
    assert ActionMailer::Base.deliveries.empty?
  end
  
  test "update should fail with invalid address" do
    request.session[:username] = 'alidrisi'
    put :update, :directory_user_id => 'alidrisi', :mail_forward => { :mail => 'new-email' }
    assert_response :success
    assert_template :edit
    assert ! assigns(:mail).errors[:mail].empty?
    
    assert Directory.connection.changes.empty?
  end
  
  test "should update mail" do
    alidrisi = Directory::User.find('alidrisi')
    alidrisi.mail_forward = 'old@example.com'
    
    request.session[:username] = 'alidrisi'
    put :update, :directory_user_id => 'alidrisi', :mail_forward => { :mail => 'new@example.com' }
    assert_redirected_to directory_user_path('alidrisi')
    
    alidrisi = Directory::User.find('alidrisi')
    assert_equal 'new@example.com', alidrisi.mail_forward
    change = Directory::MockLDAP::Change.new(alidrisi.dn, :mail, [ 'new@example.com' ])
    assert_equal [ change ], Directory.connection.changes
    
    note = ActionMailer::Base.deliveries.first
    assert note.to.include? alidrisi.mail
    assert note.cc.include? 'old@example.com'
    assert_match /new@example.com/, note.body
  end
  
  test "should update mail on Google Apps" do
    alidrisi = Directory::User.find('alidrisi')
    alidrisi.mail_forward = 'old@example.com'
    GoogleApps.connection.mock_entry('alidrisi', GoogleApps::User.new(:user_name => 'alidrisi'))
    
    request.session[:username] = 'alidrisi'
    put :update, :directory_user_id => 'alidrisi', :mail_forward => { :mail => 'new@example.com' }
    assert_redirected_to directory_user_path('alidrisi')
    
    alidrisi = Directory::User.find('alidrisi')
    assert_equal 'new@example.com', alidrisi.mail_forward
    
    assert_equal [ 'alidrisi only new@example.com' ], GoogleApps::MockTrollusk.commands
  end
  
end
