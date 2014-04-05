class Subscription < ActiveRecord::Base
  belongs_to  :argument
  belongs_to  :debate

  def self.enable(arg,depth,email,daily_digest)
    subscription_exist = find(:first,:conditions => ["email = ? and argument_id = ? and deep = ?",email,arg.id,depth])
     if !subscription_exist.blank?
       if daily_digest == '1'
          subscription_exist.update_attribute(:daily_digest , daily_digest)
       end
     else
       if !arg.parent_id.blank?
         parent_subscriptions = find(:all,:conditions => ["email = ? and argument_id in (?)",email, arg.ancestors.collect(&:id)])
         parent_subscriptions.each do |sub|
          return if arg.level_with_respective_parent(sub.argument) <= sub.deep || sub.deep == 0
         end
         create(:email => email,
                :deep => depth,
                :debate=> arg.debate,
                :argument => arg,
                :daily_digest => (!daily_digest.blank? ? daily_digest : 0),
                :status => true,
                :activation_code => self.make_token )
       else
        create(:email => email,
                :deep => depth,
                :debate=> arg.debate,
                :argument => arg,
                :daily_digest => (!daily_digest.blank? ? daily_digest : 0),
                :status => true,
                :activation_code => self.make_token )
       end
     end
  end
  
  def self.disable(activation_code)
    sub = find(:first,:conditions => ["activation_code like ? and status = 1",activation_code])
    sub.update_attributes(:status => false)
  end

  def self.enableDebate(debate,depth,email,daily_digest)
    subscription_exist = find(:first,:conditions => ["email = ? and debate_id = ? and argument_id is null",email,debate.id])
    if !subscription_exist.blank?
      if (subscription_exist.deep < depth || depth == 0) && subscription_exist.deep != 0
        subscription_exist.update_attribute(:deep , depth)
      end
      if daily_digest == '1'
          subscription_exist.update_attribute(:daily_digest , daily_digest)
      end
    else
          create(:email => email,
                :deep => depth,
                :debate=> debate,
                :daily_digest => (!daily_digest.blank? ? daily_digest : 0),
                :status => true,
                :activation_code => self.make_token )
    end
  end

  def self.secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end
  def self.make_token
    secure_digest(Time.now, (1..10).map{ rand.to_s })
  end 
end
