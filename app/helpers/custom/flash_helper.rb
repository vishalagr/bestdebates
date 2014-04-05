module Custom::FlashHelper
  FLASH_VALID_KEYS = [:error, :notice, :warning, :info, :timeout]
  
  def flash_messages(options={:fade => 30})
    return unless messages = flash.keys.select{|k| FLASH_VALID_KEYS.include?(k)}
    
    formatted_messages = messages.map do |type|      
      next if flash[type].blank? or type == :timeout
      
      html = content_tag :div, :id => "flash_#{type}" do
        message_for_item(flash[type], flash["#{type}_item".to_sym])
      end
      
      timeout = flash.has_key?(:timeout) ? (flash[:timeout].to_i)*250 : (options[:fade]*250)
      if options.key?(:fade)
        html << content_tag(:script, "setTimeout(\"new Effect.Fade('flash_#{type}');\",#{timeout})", :type => 'text/javascript')
      end
      
      html
    end
    
    formatted_messages.join('')
  end

  def message_for_item(message, item = nil)
    if item.is_a?(Array)
      message % link_to(*item)
    else
      message % item
    end
  end
  
  def reload_flashes!(options = {:fade => 30})
    page.replace_html 'flash', :inline => @context.send(:flash_messages, options)
  end
end
