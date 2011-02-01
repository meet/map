class UsersController < ApplicationController
  
  def index
    @users = Directory::User.all
  end
  
  def show
    @user = Directory::User.find(params[:id])
  end
  
  def new
    @user = Directory::User.new(Hash.new([]))
  end
  
end
