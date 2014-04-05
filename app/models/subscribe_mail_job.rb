 class SubscribeMailJob < Struct.new(:parent, :argument,:sub,:host) 
	 def perform	      
		 parent_arg = Argument.find_by_id(parent)	 
		 arg = Argument.find_by_id(argument)	 
		 subs = Subscription.find_by_id(sub)	
		 Mailers::Debate.deliver_send_subscription_email(parent_arg,arg,subs,host) 
	 end
 end