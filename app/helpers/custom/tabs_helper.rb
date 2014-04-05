module Custom::TabsHelper
  def get_tab_name(object, tab_id)
    object.class::TABS.index(tab_id)
  end
  
  def tab_validate!(object, tab)
    klass = object.class
    raise "unknown tab '#{tab}' for #{klass}" unless 
      (tab.is_a?(Integer) ? klass::TABS.values.include?(tab) : klass::TABS.keys.include?(tab.to_sym))
  end
  
  def tab_link_id(object, tab)
    tab_validate!(object, tab)
    tab.to_s.titleize << '_' << object.id.to_s
  end
  
  def tab_link_to_remote(name, tab, object)
    tab_validate!(object, tab)
    
    klass   = object.class
    tab_url = if    object.is_a?(Argument)
                argument_tab_url(object, klass::TABS[tab.to_sym])
              elsif object.is_a?(Debate)
                  debate_tab_url(object, klass::TABS[tab.to_sym])
              else
                raise "unknown tab's class given: #{klass}"
              end
    
    link_to_remote name, :url      => tab_url, 
                         :before   => "put_circle('#{tab_link_id(object, tab)}')",
                         :complete => "remove_circle('#{tab_link_id(object, tab)}');",
                         :method   => :get,
                         :html     => {:id => tab_link_id(object, tab)}
  end


  def tab_link_messages_to_remote(name)
    tab_url = if name == "Incoming"
                private_messages_path + "?folder=inbox"
              elsif name == "Sent"
                private_messages_path + "?folder=outbox"
              end
    link_to_remote name, :url      => tab_url, 
                         :before   => "put_circle('#{name}')",
                         :complete => "remove_circle('#{name}')",
                         :update => "private_messages",
                         :method   => :get                         
  end
  def use_button_link_to_remote(name,tab,object,use_object)
    tab_validate!(object, tab)

    klass   = object.class
    tab_url = if    object.is_a?(Argument)
                argument_tab_url(object, klass::TABS[tab.to_sym],:reply_arg =>use_object,:firefox_arg =>"1")
              else
                raise "unknown tab's class given: #{klass}"
              end

    link_to_remote name, :url      => tab_url,
                         :before   => "put_circle('#{tab_link_id(object, tab)}')",
                         :complete => "remove_circle('#{tab_link_id(object, tab)}');create_fckeditor('argument_#{use_object.id}_edit')",
                         :method   => :get,
                         :html     => {:id => tab_link_id(object, tab)}
  end
  
  def tab_div_id(tab, debate_or_argument)
    tab_validate!(debate_or_argument, tab)
    'div' << tab.to_s.titleize << '_' << debate_or_argument.id.to_s
  end
  
  def bookmark_tab?
    logged_in?
  end
  
  def edit_tab?(object)
    if    object.is_a?(Argument)
      raise
    elsif object.is_a?(Debate)
      can_edit_debate?(object)
    else
      raise "unknown tab's class given: #{object.class.name}"
    end
  end

  def tab_login_link(action_name)
    "<br/><span style='padding-left:7px;'>Please, #{link_to('Login', new_session_path, :id => 'login')} to #{action_name}</span>"
  end
end
