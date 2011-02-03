class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  before_filter :authenticate
  
  def logout
    reset_session
    @current_user = nil
  end
  
  private
    
    def authenticate
      return if @current_user = Directory::User.find(session[:username])
      
      authorize_with_open_id do |result, identity_url, attributes|
        reset_session
        if result.successful?
          session[:username] = attributes[:username]
          redirect_to request.url
        else
          @error = result.message
          render 'application/error', :status => 403
        end
      end
      render :file => 'public/500', :layout => false, :status => 500 unless performed?
    end
    
    def directory_user
      @user = Directory::User.find(params[:directory_user_id])
    end
    
end
