module Custom::CollectionsHelper
  def categories_list
		return @categories if @categories

#		@categories = Category.all(:conditions => (admin_user? ? nil : Category.practice_debate_params(true)), :order => 'name') # skip Practice Debates
		@categories = Category.all :order => 'name'
	end

  def category_link(category, options={})
    link_to category.name, debates_category_path_for(category), options
  end

  def debates_category_path_for(category)
    debates_path(:category_id => category.id)
  end

  def category_uri_for(name)
    c = Category.find_by_name(name) or raise ActiveRecord::RecordNotFound
    debates_category_path_for(c)
  end

	def featured_debates(f_debates)
		f_debates.collect do |d|
      content_tag(:p, "#{d.title}. #{link_to('join this topic', debate_url(d))}")
    end.join
	end
  
   def featured_debates_all_pages(f_debates)
      f_debates.collect do |d|
      content_tag(:p, "#{d.title}. #{link_to('join this topic', debate_url(d))}")
    end.join
  end
end
