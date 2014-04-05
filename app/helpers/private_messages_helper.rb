module PrivateMessagesHelper
  
  def sortable_column(col_name, sort_order)
    sort_order ||= 'asc'
    query_list = [].push('order=' + col_name + '_' + sort_order)
    if request.get?
      params.each {
        |k, v|
        if ( k != "controller" && k != "action" && k != "order" )
          query_list.push("#{k}=#{v}")
        end
      }
    end
    "<a href='/private_messages?" + query_list.join('&') +"'>" + col_name.capitalize! + "</a>"
  end

  def message_users_emails_list(users)
    options = ''
    users.collect do |u|
      options += %Q{#{u.email if !u.email.blank?}, \n}
    end
    text_field(:message, :to_users , :size => 70 , :value => options )
  end

  def remote_sortable_column(col_name, sort_order)
    sort_order ||= 'asc'
    query_list = [].push('order=' + col_name + '_' + sort_order)
    if request.get?
      params.each {
        |k, v|
        if ( k != "controller" && k != "action" && k != "order" )
          query_list.push("#{k}=#{v}")
        end
      }
    end
    link_to_remote col_name.capitalize!, :url => private_messages_path + "?" + query_list.join('&'),
                         :before   => "put_circle('#{col_name}')",
                         :complete => "remove_circle('#{col_name}')",
                         :update => "private_messages",
                         :method   => :get    
  end

end
