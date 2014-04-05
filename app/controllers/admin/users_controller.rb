class Admin::UsersController < Admin::BaseController
  before_filter :find_user, :except => [:index, :search]
  layout 'admin'
  
  # List of users
  def index
    @search_results = Admin::UsersSearch.new(params)
    @users          = @search_results.find
  end
  
  # Search for users
  def search
    index
    render :action => :index
  end
    
  # Edit the user
  def edit
    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @user }
    end
	end
  
  # Update the user
  def update
		if @user.update_attributes(params[:user])
			flash.now[:notice] = 'Your changes have been saved'
		end
		respond_to do |format|
      format.html { render :action => 'edit' }
      format.xml  { render :xml => @user }
    end		
	end
  
  # Drop the user
  def drop
    @user.delete!
    redirect_to admin_users_path
  end
  
  # Purge the user i.e., premanently delete the user record
  def purge
    @user.destroy
    redirect_to admin_users_path
  end
  
#  def edituser
#    flash.now[:notice] = ''
#    @user = User.find(params[:id])
#    respond_to do |format|
#      format.html 
#      format.xml  { render :xml => @user }
#    end
#  end
  
#  def updateuser
#    @user = User.find(params[:id])
#    #TODO: be sure i'm the owner
#    # @user = current_user unless current_user.admin?
#    if @user.update_attributes(params[:user])
#      flash.now[:notice] = 'Your changes have been saved'
#    end
#    redirect_to(listusers_path)
#  end
end
