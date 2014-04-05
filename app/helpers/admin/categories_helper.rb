module Admin::CategoriesHelper
  def dod_category_checked?(category)
    !!category.debates.of_the_day
  end
end
