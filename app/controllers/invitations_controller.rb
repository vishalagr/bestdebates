class InvitationsController < ApplicationController  
  before_filter :login_required
  before_filter :find_resource
  before_filter :can_invite
  
  # List all invitations
  def index
    load_objects
    @active_users = User.active.all(:order => 'login ASC')
    respond_to do |format|
      format.html #
      format.xml  { render :xml => @guests }
      format.js   { render :partial => 'guest', :collection => @guests}
    end
  end
  
  # Create an invitation
  # See InvitationEngine for more details
  def create
    i = InvitationEngine.new(current_user, @resource, params)
    i.proceed
    
    unless i.errors.blank?
      flash.now[:error]  = i.errors.join('<br />') 
    else
      flash.now[:notice] = "Your invitations to #{view_helpers.pluralize(i.records_count, 'user')} have been sent."
    end
    
    load_objects
        
    if i.new_users?
      respond_to do |format|
        format.js{
          render(:update){|page|
            page.reload_flashes!
            if i.errors.blank?
              page.replace_html('guests', :partial => 'guest', :collection => @guests)
              page[:emails].value = ''
            end
          }
        }
      end
    elsif i.exists_users?
      respond_to do |format|
        format.js{
          render(:update){|page|
            page.reload_flashes!
            page.replace_html 'users',  :partial => 'user',  :collection => @users
          }
        }
      end
    else
      respond_to do |format|
        format.js{ render :nothing => :true}
      end
    end
  end
  
  # Update multiple invitations
  # -- for saving current invitations after checkboxes have been modified
  # See InvitationEngine for more details
  def update_multiple
    i = InvitationEngine.new(current_user, @resource, params)
    i.update_multiple
    flash.now[:notice] = "#{view_helpers.pluralize(i.records_count, 'invitation')} was updated."
    
    load_objects
    respond_to do |format|
      format.js do
        render :update do |page|
          page.reload_flashes!
          page.replace_html 'users_and_guests',  :partial => 'users_and_guests'
          page.replace_html 'invitations_buttons', :partial => 'invitations/buttons'
        end
      end
    end
  end
  
  # Resend emails to the invitee
  def resend_email
    begin
      @invitation = Invitation.find(params[:id])
      Mailers::Debate.deliver_invitation(@invitation.invitor, @invitation.resource, @invitation)
      flash[:notice] = 'Invitation email successfully resent'
    rescue
      flash[:error] = 'Couldn\'t resend the invitation email'
    end

    respond_to do |format|
      format.js do
        render :update do |page|
          page.reload_flashes!
        end
      end
    end
  end

  # Preview the invitation email to be sent to invitees
  def preview_email
    invitation = Invitation.new(:user => current_user, :code => Code.new)
    mail = Mailers::Debate.create_invitation(current_user, @resource, invitation)
    @mail_body = mail.body.sub('No message provided', 'YOUR PERSONALIZED NOTE GOES HERE')

    render :inline => %Q{<%= simple_format(@mail_body, {:style => 'margin: 8px 0px'}) %>}
  end

  private

  # if there are replies BY SOEMONE OTHER THAN THE AUTHOR to a public debate or public argument,
  # it cannot be made private
  # should do in the DebateController

  # but if someone is invited to see a debate WHEN it is public,
  # but before there are replies by someone other than the author,
  # and THEN the author makes it private -
  # then YES, the person will not be able to see it

  # If it is public all users can invite other to it
  # But if it is privet only the owner can make invitations to it
  # May be owner invite someone and another user invite him so owner can see both
  # and it will display popup saying who invite this user
  
  def can_invite
    unless @resource.can_be_invited_by?(current_user)
      flash[:error] = 'You can\'t invite!'
      redirect_to (@resource_type == 'Argument') ? argument_path(@resource) : debate_path(@resource) 
    end
  end

  # debate owner can see all who invited to see his debate, but other user only can see who they invite
  def load_objects
    @guests, @users = @resource.can_be_modified_by?(current_user) ? [@resource.guests, @resource.invited_users] : 
      [
        @resource.guests(["invitor_id = '#{current_user.id}'"]), 
        @resource.invited_users.all(:conditions => ['invitor_id = ?', current_user])
      ]
  end
end
