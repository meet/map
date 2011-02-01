require 'test_helper'

class MailsControllerTest < ActionController::TestCase
  
  test "should get edit page for admin self" do
    request.env['REMOTE_USER'] = 'ptolemy'
    get :edit, :directory_user_id => 'ptolemy'
    assert_response :success
    assert_template :edit
  end
  
  test "should get edit page self" do
    request.env['REMOTE_USER'] = 'alidrisi'
    get :edit, :directory_user_id => 'alidrisi'
    assert_response :success
    assert_template :edit
  end
  
  test "should get edit page for admin" do
    request.env['REMOTE_USER'] = 'ptolemy'
    get :edit, :directory_user_id => 'alidrisi'
    assert_response :success
    assert_template :edit
  end
  
  test "edit should be denied" do
    request.env['REMOTE_USER'] = 'alidrisi'
    get :edit, :directory_user_id => 'ptolemy'
    assert_response :forbidden
  end
  
  test "should update mail by admin" do
    request.env['REMOTE_USER'] = 'ptolemy'
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
    request.env['REMOTE_USER'] = 'alidrisi'
    put :update, :directory_user_id => 'ptolemy', :mail_forward => { :mail => 'example@example.com' }
    assert_response :forbidden
    
    ptolemy = Directory::User.find('ptolemy')
    assert_equal nil, ptolemy.mail_forward
    assert Directory.connection.changes.empty?
    
    assert ActionMailer::Base.deliveries.empty?
  end
  
  test "update should fail with invalid address" do
    request.env['REMOTE_USER'] = 'alidrisi'
    put :update, :directory_user_id => 'alidrisi', :mail_forward => { :mail => 'new-email' }
    assert_response :success
    assert_template :edit
    assert ! assigns(:mail).errors[:mail].empty?
    
    assert Directory.connection.changes.empty?
  end
  
  test "should update mail" do
    alidrisi = Directory::User.find('alidrisi')
    alidrisi.mail_forward = 'old@example.com'
    
    request.env['REMOTE_USER'] = 'alidrisi'
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
  
end
