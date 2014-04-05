class Argument < ActiveRecord::Base
  validates_presence_of :debate_id, :user_id
	validates_presence_of :title, :argument_type , :body #, :evidence_type
	#validates_length_of   :title, :maximum => 220, :allow_blank => true
    # disabled for now
	# validates_length_of :clarification, :maximum => 100, :allow_blank => true
	# validates_length_of :reasoning, :maximum => 100, :allow_blank => true
	# validates_length_of :evidence, :maximum => 100, :allow_blank => true
	# validates_length_of :body, :maximum => 750, :allow_blank => true	
	validates_inclusion_of :argument_type, :in => %w( pro con com),
		:message => "must be of type 'pro' or 'con' or com",
		:unless => Proc.new{|argument| argument.argument_type.blank?}
#	validates_inclusion_of :evidence_type, :in => %w( support undermine ),
#		:message => "%s is not a valid evidence type (must be 'support' or 'undermine')",
#		:unless => Proc.new{|argument| argument.evidence_type.blank?}
 validate do |arg|
   if arg.title.size > 220
     arg.errors.add("Your title"," is #{arg.title.size} characters, Titles must be less than 220 characters.")    
   end
 end

  validate do |arg|
    chk_body = Sanitize.clean(arg.body,  Sanitize::Config::BASIC) unless arg.body.blank?
   if chk_body == DEFAULT_ARGUMENT_TEXT
     arg.errors.add("Please Enter Argument clarification,It is empty or ")   
   end
 end
end
