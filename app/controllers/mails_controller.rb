class MailsController < ApplicationController
  
  before_filter :directory_user
  before_filter :google_apps_user
  
  def edit
    if @current_user.is?(@user) or @current_user.admin?(@user)
      @mail = MailForward.new(@user)
      render :edit
    else
      render :nothing => true, :status => 403
    end
  end
  
  def update
    if not (@current_user.is?(@user) or @current_user.admin?(@user))
      render :nothing => true, :status => 403 and return
    end
    
    @mail = MailForward.new(@user, params[:mail_forward])
    
    if @mail.valid?
      old_mail = @user.mail_forward
      GoogleApps::Trollusk.connect { |t| t.only(@user.username, @mail.mail) } if @gapps_user
      @user.mail_forward = @mail.mail
      Notify.mail_forward_update(@user, @current_user, old_mail).deliver
      flash[:message] = render_to_string :partial => 'updated'
      redirect_to @user
    else
      render :edit
    end
  end
  
end
