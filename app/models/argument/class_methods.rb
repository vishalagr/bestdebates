class Argument < ActiveRecord::Base
  
  named_scope :draft, lambda{|*is_not| 
    is_not[0] = true if is_not[0].nil?
    {:conditions => {:draft => is_not[0]}} 
  }

  named_scope :publics, lambda {
    {:conditions => {:draft => false}}
  }

  named_scope :all_not_definable, :conditions => {:definition_id => nil}
  
  class << self
    
    # Returns all arguments whose body or title attributes contains
    # the given search_term or arguments that are tagged by the search_term
    def all_with_search_term(search_term)
      args = self.search search_term.to_s+'*', :field_weights => {:title => 5, :body => 1}
      args + Argument.find_tagged_with(search_term, :conditions => ["arguments.id not in (?)", args.collect(&:id)])
    end
    
    # Returns a new child of the parent +parent+ with attributes +attributes+
    def create_child(attributes, parent = nil)
      argument = Argument.new(attributes)
      unless argument.save
        argument.dest_id = parent.id if parent # reassign parent
        return argument 
      end
      
      argument.move_to_child_of(parent) if parent && argument.errors.blank?
      argument
    end
    
    # Returns the best argument given type +type+ and category +category+
    def best_by_type_and_category(type, category = nil)
      conditions = ["debates.is_live = ? AND debates.priv = ? AND arguments.argument_type = ? AND debates.category_id != ?",
                    true, false, type, Category.practice_debate]
      if category
        conditions[0] += " AND debates.category_id = ?"
        conditions << category
      end
      
      Argument.first :joins => :debate, :conditions => conditions, :order => 'arguments.score desc'
    end

    # crontab for 3pm pacific time.
    def argument_daily_digest
     subscriptions = Subscription.find(:all , :conditions => ['status = 1 && daily_digest = 1 && argument_id is not null'])
     subscriptions.each do |sub|
       Mailers::Debate.deliver_send_subscription_email("",sub.argument,sub,HOST_DOMAIN)
     end
    end


    # TODO rebuild the records' select method
    # Returns paginated list of recent arguments visible to the given user +u+
    def recent(u, params)
      Argument.publics.all(:conditions => {:debate_id => Debate.public.without_practice_debate.collect(&:id)},
                           :order      => 'arguments.id DESC').select{|a| a.visible_to?(u)}.paginate :page => params[:page], :per_page => 50
    end
  end
end
