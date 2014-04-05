class Facebook::ProfilePublisherController < Facebook::BaseController
  skip_before_filter :ensure_authenticated_to_facebok
  protect_from_forgery :only => [:nothing]

  # ...
  def index
    if current_user.nil? and facebook_params[:user]
      self.current_user = User.for(facebook_params[:user])
    end

    # @defender = User.for(params[:fb_sig_profile_user])
    if wants_interface?
      render_publisher_interface render_to_string(:partial => 'form')
    else
#      attack = Attack.new params[:app_params][:attack]
#      @attack = current_user.attack @defender, attack.move
#      render_publisher_response AttackPublisher.create_attack_feed('test')
    end
  end
end
