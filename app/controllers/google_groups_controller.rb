class GoogleGroupsController < ApplicationController
  
  def show
    @group = GoogleApps::Group.find(params[:id])
    respond_to do |format|
      format.json do
        render :json => {
          :group_id => @group.group_id,
          :members => @group.members.all.map { |mem|
            {
              :mail => mem.member_id,
              :name => mem.member_id.sub("@#{GoogleApps::connection.domain}", '')
            }
          }
        }
      end
    end
  end
  
end
