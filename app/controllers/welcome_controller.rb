class WelcomeController < ApplicationController
  
  def index
  end
  
  def search
    query = params[:q]
    @users = Directory::User.search(query).sort_by(&:name)
    @groups = Directory::Group.search(query).sort_by(&:name)
    respond_to do |format|
      format.json { render :json => { :users => @users, :groups => @groups } }
    end
  end
  
end
