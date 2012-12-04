class UsersController < ApplicationController
  
  def index
    @users = Directory::User.all
  end
  
  def show
    @user = Directory::User.find(params[:id])
  end
  
end
