class Admin::CategoriesController < Admin::BaseController
  # List of all categories
  def index
    @category = Category.new
  end
  
  # Create a category
  def create
    if Category.new(params[:category]).save
      flash[:notice] = 'New category was successfully created!'
    else
      flash[:error] = 'Error in creating new category. All attributes must be filled!'
    end
    
    redirect_to admin_categories_url
  end
  
  # POST
  # update debates' is_live for categories id array
  def update
    if params[:ids].blank?
      flash[:error] = 'Categories list is empty' and redirect_to admin_categories_url and return
    end
    
    Category.find(params[:ids].keys).each do |category|
      category.debates.update_all ["is_live = ?", params[:ids][category.id.to_s].to_i]
    end
    
    flash[:notice] = 'Debates\' status was updated!'
    redirect_to admin_categories_url
  end
  
  # Destroy the category
  # Do a cascading retire! of all debates belonging to it
  def destroy
    Category.transaction do
      category = Category.find(params[:id])
      category.debates.each(&:retire!) #retire, don't destroy
      category.destroy
    end
    
    flash[:notice] = 'all debates of the destroyed category was retired!'
    redirect_to admin_categories_url
  end
  
  # Get the debate of day
  def debate_of_day
    return if request.get? # GET template render
      
    Debate.update_all ['is_debate_of_day = ?', false] # unset all debates
    Debate.update_all ['is_debate_of_day = ?', true], {:category_id => params[:categories_id]}
    
    flash.now[:notice] = 'Your Debate of the day Has Been saved.'
  end
end
