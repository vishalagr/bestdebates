class Mailers::Debate < Mailers::BaseMailer
  helper :arguments

  # Sends the invitation email corresponding to the invitation +invitation+,
  # +debate+ and +invitor+
  def invitation(invitor, resource, invitation)
    setup_email(invitation.user ? invitation.user.email : invitation.email)
    @resource_type = resource.class.to_s.downcase
    @subject += "You have been invited to view #{@resource_type} '#{resource.title}'"
    
    @body = {
      :resource      => resource,
      :resource_type => @resource_type,
      :code          => invitation.code,
      :invitor       => invitor,
      :invitation    => invitation
    }
    content_type "text/html"
  end

  # Sends an email the list of all descendants of the argument +argument+
  # until depth +depth+ to +email_addr+
  def send_email(argument, depth, email_addr,host_url)
    setup_email(email_addr)
    @subject += argument.title

    @body = {:argument => argument, :depth => depth,:host_url=>host_url }
    content_type "text/html"
  end

  def debate_send_email(debate, depth, email_addr,host_url)
    setup_email(email_addr)
    @subject += debate.title

    @body = {:debate => debate, :depth => depth,:host_url=>host_url }
    content_type "text/html"
  end
  # Sends an email subscription for given depth of an argument.
  def send_subscription_email(parent_arg,argument,subscription,host_url)
    setup_email(subscription.email)
    @subject += argument.title  
    @body = {:argument => argument, :depth => subscription.deep , :parent_arg => parent_arg,:subscription => subscription,:host_url=>host_url }
    content_type "text/html"
  end

  def global_admin_watching_email(argument_or_debate)
    setup_email("watching@bestdebates.com")
    @subject += argument_or_debate.title
    @body = {:argument_or_debate => argument_or_debate,:host_url=>HOST_DOMAIN}
    content_type "text/html"
  end
  
  # Sends an email to the admin stating that the given +debate_or_argument+ is offesive
  def offensive_report(debate_or_argument, user)
    setup_email('admin@bestdebates.com')
    content_type 'text/html'

    @from     = 'offensive@bestdebates.com'
    @subject += 'Offensive Argument/Debate'
    link  = (debate_or_argument.is_a?(Debate)) ? debate_url(debate_or_argument) : argument_url(debate_or_argument)

    @body = {:link => link, :obj => debate_or_argument, :user => user}
    content_type "text/html"
  end
end
