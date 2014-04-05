class Admin::GroupsController < Admin::BaseController
  make_resourceful do
    actions :index, :show, :new, :create

    before :show do
      @members = @group.members.all
    end
    
    before :create do
      @group.creator = current_user
    end	
  end
end
