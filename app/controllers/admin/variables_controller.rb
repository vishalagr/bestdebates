class Admin::VariablesController < Admin::BaseController  
	protect_from_forgery 

	make_resourceful do
    actions :all    
  end

  # Activate the variable
  def activate
    Variable.update_all('active = 0', ["id != ?", params[:id].to_i])
    Variable.update_all('active = 1', ["id  = ?", params[:id].to_i])
    
    redirect_to admin_variables_url
  end
end
