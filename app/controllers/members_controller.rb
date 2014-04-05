#class MembersController < ApplicationController
#
#  before_filter :login_required
#  before_filter :group_owner_required, :only => [:new, :create]
#  before_filter :owner_required,       :only => [:edit, :update, :destroy]
#  
#  make_resourceful do
#    actions :all
#    belongs_to :group
#
#    before :show do
#      @group = @member.group
#    end
#
#    response_for :destroy do |format|
#      format.html do
#        flash[:notice] = "Member deleted!"
#        redirect_to group_members_path(@group)
#      end
#      format.xml{ head :ok }
#      format.js
#    end
#  end
#
#  private
#
#  def group_owner_required
#    @group = Group.find(params[:group_id])
##    check_owner
#  end
#  
#  def owner_required
#    load_object
#    @group = @member.group
##    check_owner
#  end
#
##  def check_owner
##    return false unless logged_in? and @group.owner?(current_user)
##  end
#  
#end
