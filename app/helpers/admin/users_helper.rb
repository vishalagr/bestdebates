module Admin::UsersHelper
  def admin_sort_link(title, sort_by, search_results, options = {})
    order = search_results.order_by == 'ASC' ? 'DESC' : 'ASC'
    link_to title, search_admin_users_url("search[order_by]" => order, "search[sort_by]" => Admin::UsersSearch::SORTS[sort_by]), options
  end
end
