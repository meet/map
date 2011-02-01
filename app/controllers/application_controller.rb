class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  before_filter :authenticate
  
  private
    
    def authenticate
      @current_user = Directory::User.find(request.env['REMOTE_USER'])
    end
    
    def directory_user
      @user = Directory::User.find(params[:directory_user_id])
    end
    
end
