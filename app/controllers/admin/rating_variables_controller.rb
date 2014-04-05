class Admin::RatingVariablesController < Admin::BaseController
  protect_from_forgery

  make_resourceful do
    actions :all
  end

  # Activate the variable
  def activate
    RatingVariable.update_all('active = 0', ["id != ?", params[:id].to_i])
    RatingVariable.update_all('active = 1', ["id  = ?", params[:id].to_i])

    redirect_to admin_rating_variables_url
  end
end
