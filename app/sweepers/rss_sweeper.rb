class RssSweeper < ActionController::Caching::Sweeper
  observe Argument

  def after_create(argument)
    expire_cache_for(argument)
  end
  
  def after_save(argument)
    expire_cache_for(argument) unless argument.new_record?
  end
  
  def after_destroy(argument)
    expire_cache_for(argument)
  end
          
  private
  
  def expire_cache_for(argument)
    expire_cache(argument)
    expire_cache_for(argument.parent) if argument.parent
  end
  
  def expire_cache(argument)
    # expiring all rss deeps
    argument_rss_path = "/arguments/#{argument.id}/rss"
    expir_path = File.join(Rails.root, 'public', argument_rss_path)
    if File.exist?(expir_path)
      Rails.logger.info "Expired RSS page: #{argument_rss_path}"
      FileUtils.rm_rf(expir_path) 
    end
  end
end