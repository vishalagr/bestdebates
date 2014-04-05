class Admin::UserVariablesController < Admin::BaseController  
  protect_from_forgery 
  
  make_resourceful do
    actions :all
  end
  
  # Activate the variable
  def activate
    UserVariable.update_all('active = 0', ["id != ?", params[:id].to_i])
    UserVariable.update_all('active = 1', ["id  = ?", params[:id].to_i])
    
    redirect_to admin_user_variables_url
  end
end
