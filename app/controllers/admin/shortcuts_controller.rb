class Admin::ShortcutsController < Admin::BaseController  
  protect_from_forgery

  make_resourceful do
    actions :all
  end

  def show 
  redirect_to objects_path  
  end

end
