class PasswordsController < ApplicationController
  
  before_filter :directory_user
  before_filter :google_apps_user
  
  def edit
    @password = Password.new(@user)
    if @current_user.is?(@user)
      render :edit
    elsif @current_user.admin?(@user)
      render :reset
    else
      render :nothing => true, :status => 403
    end
  end
  
  def create
    if not @current_user.admin?(@user)
      render :nothing => true, :status => 403 and return
    end
    
    temporary = Password.random
    @user.enabled = false
    @user.password = temporary
    Notify.password_reset(@user, @current_user, temporary).deliver
    flash[:message] = render_to_string :partial => 'reset'
    redirect_to @user
  end
  
  def update
    if not @current_user.is?(@user)
      render :nothing => true, :status => 403 and return
    end
    
    @password = Password.new(@user, params[:password])
    
    if @password.valid?
      @user.enabled = true
      @user.password = @password.new_password
      
      if @gapps_user
        @gapps_user.password = @password.new_password
        @gapps_user.save
      end
      
      flash[:message] = render_to_string :partial => 'updated'
      redirect_to @user
    else
      render :edit
    end
  end
  
end
