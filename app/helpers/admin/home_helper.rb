module Admin::HomeHelper
  def sort_link_to_remote(title, column, options = {}, sort_defalut = 'up')
    sort_dir = (params[:c] == column.to_s && params[:d] == sort_defalut) ? sort_defalut == 'up' ? 'down' : 'up' : sort_defalut
    link_to_remote title, :url => request.parameters.merge( {:c => column, :d => sort_dir} ),
                          :update => options[:update]
  end

  def variable_title(var)
    if var && var.active?
      '<b>' << var.details << '</b>'
    else
      var.details if var
    end
  end
  
  def timeline_links(action)
    a = ActiveSupport::OrderedHash.new
    a['Today']     = (Date.today + 7.hours) 
    a['This Week'] = (Date.today - 7.days) 
    a['30']        = (Date.today - 30.days) 
    a['60']        = (Date.today - 60.days) 
    a['90']        = (Date.today - 90.days)
    a.collect do |name, start_time|
      link_to_remote name, :update => "stats_display", :url => {:action => action, :start_time => start_time}
    end.join(' | ')
  end
end
