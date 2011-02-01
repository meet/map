class GroupsController < ApplicationController
  
  def index
    @groups = Directory::Group.all
  end
  
  def show
    @group = Directory::Group.find(params[:id])
  end
  
end
