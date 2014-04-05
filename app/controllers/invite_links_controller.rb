class InviteLinksController < ApplicationController  
  before_filter :login_required
  before_filter :find_resource
  before_filter :invite_permission_check

  # List of all invite_links
  def index
    @invite_links = @resource.invite_links
    render :layout => false
  end

  # New invite_link
  def new
    @invite_link = InviteLink.new
    render :layout => false
  end

  # Create/generate invite_link
  def create
    @invite_link = InviteLink.create(
      :resource_id   => @resource.id,
      :resource_type => @resource_type,
      :user_id       => current_user.id,
      :title         => params[:title],
      :unique_id     => current_user.id.to_s + @resource.id.to_s + Time.now.strftime('%Y%m%d%H%M%S')
    )
    render :layout => false
  end

  # List of all invited users (user who have joined the
  # resource using the invite_link) of the invite_link
  def invited_users
    @invite_link = InviteLink.find(params[:id])
    @users = @invite_link.invited_users

    render :partial => 'invited_users', :layout => false, :locals => {:users => @users, :invite_link => @invite_link}
  end

  private

  # before_filter to check whether the +current_user+ is 
  # authorized to invite users to the resource
  def invite_permission_check
    unless can_edit_resource?(@resource)
      error = "You don't have access to invite to this #{@resource_type.downcase}"
      respond_to do |format|
        format.html do
          flash[:error] = error
          redirect_to self.send("#{@resource_type.downcase}_url", @resource)
        end
        format.js   {
          render(:update){|page| flash.now[:error] = error; page.reload_flashes!}
        }
      end
    end
  end
end
