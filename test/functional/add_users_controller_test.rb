require 'test_helper'

class AddUsersControllerTest < ActionController::TestCase
  
  def setup
    super
    
    # Necessary groups
    Directory.connection.mock_group(:cn => 'all-staff',
                                    :description => 'All Staff',
                                    :memberuid => [ 'ptolemy', 'alidrisi' ])
    Directory.connection.mock_group(:cn => 'managers',
                                    :description => 'Managers',
                                    :memberuid => [ 'ptolemy' ])
    GoogleApps.connection.mock_customer('abcd1234')
    GoogleApps.connection.mock_entry('all-staff', GoogleApps::Group.new(:group_id => 'all-staff'))
    
    # User to receive request
    @alzuhri = {
      :first_name => 'Mohammed', :last_name => 'al-Zuhri',
      :mail_forward => 'alzuhri@ancient.carto',
      :primary_group => 'all-staff'
    }
    
    # User with pending request
    Directory.connection.mock_new_user(:cn => 'abc123',
                                       :givenname => 'Ibn', :sn => 'Battuta',
                                       :mail => 'ibnbattuta@ancient.travel',
                                       :ou => 'all-staff',
                                       :manager => Directory::User.find('ptolemy').dn)
    # ... and org-user entry that would magically appear when real user is created
    GoogleApps.connection.mock_entry('ibnb@example.com', GoogleApps::OrgUser.new(:org_user_email => 'ibnb@example.com'))
  end
  
  test "should be denied" do
    request.session[:username] = 'alidrisi'
    get :new
    assert_response :forbidden
  end
  
  test "should not allow request with duplicate mail" do
    request.session[:username] = 'ptolemy'
    post :create, :directory_new_user => @alzuhri.merge({ :mail_forward => 'alidrisi@ancient.carto' })
    assert_response :success
    assert_template :new
    assert_equal [ 'already in use' ], assigns(:user).errors[:mail_forward]
    
    assert Directory.connection.changes.empty?
  end
  
  test "should send request" do
    request.session[:username] = 'ptolemy'
    post :create, :directory_new_user => @alzuhri
    assert_redirected_to root_path
    
    assert ! Directory.connection.changes.empty?
    cn = Directory.connection.changes.find { |change| change.attribute == :cn } .value
    entry = Directory::NewUser.find_and_update(cn)
    @alzuhri.each do |key, value|
      assert_equal value, entry.send(key)
    end
    
    note = ActionMailer::Base.deliveries.first
    assert_equal [ @alzuhri[:mail_forward] ], note.to
    assert_match add_user_path(cn), note.body
  end
  
  test "should send request after warning" do
    request.session[:username] = 'ptolemy'
    post :create, :directory_new_user => @alzuhri.merge({ :last_name => 'al-zuhri' })
    assert_response :success
    assert_template :new
    assert_equal 'should be capitalized properly', assigns(:user).warnings[:last_name]
    
    assert Directory.connection.changes.empty?
    
    post :create, :directory_new_user => @alzuhri.merge({ :last_name => 'al-zuhri', :warned => 'last_name' })
    assert_redirected_to root_path
    
    assert ! Directory.connection.changes.empty?
    cn = Directory.connection.changes.find { |change| change.attribute == :cn } .value
    assert Directory::NewUser.find_and_update(cn)
  end
  
  test "should show pending users" do
    request.session[:username] = 'ptolemy'
    get :new
    assert_equal [ 'Ibn Battuta' ], assigns(:pending).map(&:name)
  end
  
  test "should be denied when logged in" do
    get :show, :id => 'abc123'
    assert_response :success
    assert_template :show
    
    request.session[:username] = 'ptolemy'
    get :show, :id => 'abc123'
    assert_response :forbidden
    put :update, :id => 'abc123'
    assert_response :forbidden
  end
  
  test "should not allow user with duplicate username" do
    put :update, :id => 'abc123', :directory_new_user => { :username => 'alidrisi' }
    assert_response :success
    assert_template :show
    assert ! assigns(:user).errors[:username].empty?
    
    assert Directory.connection.changes.empty?
  end
  
  test "should continue to set password" do
    put :update, :id => 'abc123', :directory_new_user => { :username => 'ibnb', :mail_inbox => 'true' }
    assert_redirected_to edit_directory_user_password_path('ibnb')
    assert_equal 'ibnb', request.session[:username]
    
    assert Directory::User.find('ibnb')
  end
  
  test "should create local user" do
    pending = Directory::NewUser.find_and_update('abc123')
    put :update, :id => 'abc123', :directory_new_user => { :username => 'ibnb', :mail_inbox => 'true' }
    assert_response :redirect
    
    assert ! Directory.connection.changes.empty?
    ibnb = Directory::User.find('ibnb')
    staff = Directory::Group.find('all-staff')
    expected = [
      Directory::MockLDAP::Change.new(pending.dn, :dn, nil),
      Directory::MockLDAP::Change.new(ibnb.dn, :dn, ibnb.dn),
      Directory::MockLDAP::Change.new(ibnb.dn, :uid, [ 'ibnb' ]),
      Directory::MockLDAP::Change.new(ibnb.dn, :destinationindicator, [ 'inbox' ]),
      Directory::MockLDAP::Change.new(staff.dn, :memberuid, [ 'ptolemy', 'alidrisi', 'ibnb' ])
    ]
    assert_equal [], expected - Directory.connection.changes
  end
  
  test "should create Google Apps user" do
    put :update, :id => 'abc123', :directory_new_user => { :username => 'ibnb', :mail_inbox => 'true' }
    assert_response :redirect
    
    assert_equal 3, GoogleApps.connection.changes.size
    expected = [
      [ 'POST', /\/user\//, /userName=.ibnb./ ],
      [ 'PUT', /\/orguser\/.*ibnb/, /value=.#{GoogleApps::ORG_UNIT_GROUPS['all-staff']}./ ],
      [ 'POST', /\/group\/.*\/all-staff\/member/, /value=.ibnb@example.com./ ]
    ].zip(GoogleApps.connection.changes).each do |expects, actuals|
      expects.zip(actuals).each do |expect, actual|
        assert_match expect, actual.to_s
      end
    end
  end
  
  test "should send notification" do
    put :update, :id => 'abc123', :directory_new_user => { :username => 'ibnb', :mail_inbox => 'true' }
    assert_response :redirect
    
    note = ActionMailer::Base.deliveries.first
    assert_equal [ 'ibnbattuta@ancient.travel', 'ptolemy@example.com' ], note.to
    assert_match /Your username is ibnb/, note.body
  end
  
end
