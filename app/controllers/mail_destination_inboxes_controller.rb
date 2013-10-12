class MailDestinationInboxesController < ApplicationController
  
  before_filter :directory_user
  before_filter :google_apps_user
  
  def edit
    if @current_user.is?(@user) or @current_user.admin?(@user)
      @mail_destination = MailDestination.new(@user)
      render :edit
    else
      render :nothing => true, :status => 403
    end
  end
  
  def update
    if not (@current_user.is?(@user) or @current_user.admin?(@user))
      render :nothing => true, :status => 403 and return
    end
    
    @mail_destination = MailDestination.new(@user, params[:mail_destination])
    
    if @mail_destination.valid?
      old_destination_inbox = @user.mail_destination_inbox
      new_destination_inbox = @mail_destination.mail_destination_inbox == "true"
      
      if old_destination_inbox == new_destination_inbox
        flash[:message] = render_to_string :partial => 'no_change'
        redirect_to @user and return
      end
      destination_string = (@mail_destination.mail_destination_inbox == "true" && "inbox") || @user.mail_forward
      begin
        GoogleApps::Trollusk.connect { |t| t.only(@user.username, destination_string) } if @gapps_user
        @user.mail_destination_inbox = (@mail_destination.mail_destination_inbox == "true")
        Notify.mail_destination_inbox_update(@user, @current_user, @user.mail_forward).deliver
        flash[:message] = render_to_string :partial => 'updated'
        redirect_to @user
      rescue
        flash[:message] = render_to_string :partial => 'problem'
        redirect_to @user
      end
    else
      render :edit
    end
  end
  
end
