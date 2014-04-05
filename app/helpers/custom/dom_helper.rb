module Custom::DomHelper
  def mktree_node_dom_id(object_or_id)
    return unless object_or_id
    id = object_or_id.is_a?(Integer) ? object_or_id : object_or_id.id
    "mktree_node_#{id}"
  end
  
  def external_links_dom_id(arg)
    "external_links#{arg.id}"
  end
   def login_links_dom_id(arg)
    "login_links#{arg.id}"
  end
  def argument_id(argument, revert=false)
    l = lambda{|v| (v ? (argument.parent_id or (params[:id] or params[:parent_id]).dup or argument.debate.id) : argument.id).to_s}
    if revert
      l.call !argument.new_record?
    else
      l.call  argument.new_record?
    end
  rescue
    ''
  end
  def debate_id(debate,argument, revert=false)
    l =  debate.id.to_s
    if revert
      l.call !argument.new_record?
    else
      l.call  argument.new_record?
    end
  rescue
    ''
  end
  
  def argument_rate_id(argument)
    "rate#{argument.id}"
  end

  def watching_id(argument_or_debate)
    "watching#{argument_or_debate.id}"
  end
  
  def argument_ul_dom_id(argument)
    'a_' << argument.id.to_s
  end
  
  def form_id(argument, revert=false)
    argument_id(argument, revert) << (argument.new_record? ? '_reply' : '_edit')
  end
  
   def debate_form_id(argument,debate, revert=false)
    debate_id(debate,argument, revert) << (argument.new_record? ? '_reply' : '_edit')
  end
  
  def editor_id(argument)
    "argument_" << form_id(argument) << "_body_editor"
  end
  
  def title_id(argument)
    "argument_title_" << form_id(argument)
  end
  def image_dom_id(argument)
    "image_" << argument.id.to_s
  end
  def video_dom_id(argument)
    "video_" << argument.id.to_s
  end
  def unique_id
    @unique_id ||= (
      t = Time.now
      "#{t.min}_#{t.sec}_#{t.to_f.to_s.split('.')[1]}"
    )
  end
  
  def reset_unique_id
    @unique_id = nil
  end
  
  def rating_form_id(argument)
    "rating_form_#{argument.id}"
  end
  
  def arg_popup_dom_id(argument)
    "arg_popup#{argument.id}"
  end
   def arg_popup_full_dom_id(argument)
    "arg_popup_full#{argument.id}"
  end
  def debate_dom_id(debate)
    "debate#{debate.id}"
  end
  def use_dom_id(argument)
    "use#{argument.id}"
  end
  def more_less_link_dom_id(argument_or_debate)
    "more_less_link#{argument_or_debate.id}"
  end
  def overview_link_dom_id(argument)
    "overview_link#{argument.id}"
  end
  def fulltext_link_dom_id(argument)
    "fulltext_link#{argument.id}"
  end
  def toggle_div_cancel(argument_or_debate)
    "toggle_div_cancel('#{argument_or_debate.id}')"
  end
  
  def bookmark_dom_id(object)
    if    object.is_a?(Argument)
      "bookmark_link_argument_#{object.id}"
    elsif object.is_a?(Debate)
      "bookmark_link_debate_#{object.id}"
    else
      raise "unknown tab's class given: #{object.class.name}"
    end
  end
  
  def thumb_dom_id(object)
    "thumb#{object.id}"
  end
  def star_dom_id(object)
    "star#{object.id}"
  end
  def anti_dom_id(object)
    "anti" #{object.id}"
  end
  def taggable_object_dom_id(taggable_object)
    taggable_object.class.to_s.downcase << taggable_object.id.to_s << 'tags'
  end

  ### Ratings
  def accuracy_tooltip_dom_id
    "accuracy_tooltip#{unique_id}"
  end

  def clarity_tooltip_dom_id
    "clarity_tooltip#{unique_id}"
  end

  def relevance_tooltip_dom_id
    "relevance_tooltip#{unique_id}"
  end

  def accuracy_dom_id
    "accuracy#{unique_id}"
  end

  def clarity_dom_id
    "clarity#{unique_id}"
  end
  
  def relevance_dom_id
    "relevance#{unique_id}"
  end

  def score_dom_id(uid)
    "score_#{uid}"
  end

  def save_rating_dom_id(uid)
    "save_rating#{uid}"
  end
  ### END Ratings
end
