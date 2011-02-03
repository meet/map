class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  before_filter :authenticate
  
  def logout
    reset_session
    @current_user = nil
  end
  
  private
    
    def authenticate
      if @current_user = Directory::User.find(session[:username])
        return true
      end
      
      authorize_with_open_id do |result, identity_url, attributes|
        reset_session
        if result.successful?
          session[:username] = attributes[:username]
          @current_user = Directory::User.find(session[:username])
          return true
        else
          render :text => result.message, :status => 403
        end
      end
      return false
    end
    
    def directory_user
      @user = Directory::User.find(params[:directory_user_id])
    end
    
end
