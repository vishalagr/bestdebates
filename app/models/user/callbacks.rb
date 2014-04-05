class User < ActiveRecord::Base
  attr_accessor :skip_activation
  
  before_save  :make_activation_code  
  before_validation_on_update  :password_edit_validation
  
  #after_create :deliver_activation  
  after_save   :deliver_signup_notification
  
  # Deliver the activation email to the user. Skips it if skip_activation is false
  def deliver_activation
    if self.state != "active" && !self.email.blank?
      Mailers::User.deliver_activation(self) unless !!skip_activation
    end
  end
  
  # Deliver the signup notification to the user if the user is recently_activated?
  def deliver_signup_notification
   if !self.email.blank?
    Mailers::User.deliver_signup_notification(self) if self.recently_activated?
   end
  end
  
  protected

  # Validation for non - standard_user?
  # Restricts non - standard_user? s from changing their passwords
  def password_edit_validation
    if (!!password || !!password_confirmation) && !can_change_password?
      errors.add :password, 'You can\'t edit password because using non-password based authentication'
      return false # return validation error
    end
  end
  
  # Generate an activation_code if it is not already present
  def make_activation_code
    unless activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
    end
  end
end
