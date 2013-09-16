class AddUsersController < ApplicationController
  
  before_filter :authenticate_manager, :except => [ :show, :update ]
  skip_before_filter :authenticate, :only => [ :show, :update ]
  before_filter :unauthenticate, :only => [ :show, :update ]
  
  def new
    @user = Directory::NewUser.new
    @pending = Directory::NewUser.all
  end
  
  def create
    @user = Directory::NewUser.new(params[:directory_new_user].merge({
      :requester => @current_user
    }))
    @pending = Directory::NewUser.all
    if @user.valid_to_save?
      @user.save
      Notify.user_request(@user).deliver
      flash[:message] = render_to_string :partial => 'requested'
      redirect_to :root
    else
      render :new
    end
  end
  
  def show
    @user = Directory::NewUser.find_and_update(params[:id])
  end
  
  def update
    @user = Directory::NewUser.find_and_update(params[:id], params[:directory_new_user])
    if @user.valid_to_create?
      
      # Create local user
      @created = @user.create
      session[:username] = @created.username
      Notify.user_created(@created, @user.requester).deliver
      
      # Create Google user
      GoogleApps::User.new(
        :user_name => @created.username,
        :given_name => @created.first_name,
        :family_name => @created.last_name,
        :password => Password.random
      ).save
      GoogleApps::OrgUser.new(
        :org_user_email => "#{@created.username}@#{GoogleApps.connection.domain}",
        :org_unit_path => GoogleApps::ORG_UNIT_GROUPS[@user.primary_group]
      ).save
      
      # Add to Google group
      GoogleApps::Group.find(@user.primary_group).members.new(
        :member_id => @created.mail
      ).save
      
      redirect_to edit_directory_user_password_path(@created)
    else
      render :show
    end
  end
  
  def resend_email
    @user = Directory::NewUser.find_and_update(params[:id])
    Notify.user_request(@user).deliver
    redirect_to :root
  end

  private
    
    def authenticate_manager
      if not @current_user.manager?
        render :nothing => true, :status => 403
      end
    end
    
    def unauthenticate
      if session[:username]
        @error = 'Not a new user'
        render 'application/error', :status => 403
      end
    end
    
end
