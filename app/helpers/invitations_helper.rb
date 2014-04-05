module InvitationsHelper
  def invitations_users_list(users)
    options = ''
    users.collect do |u|
      options += %Q{<option value="#{u.id}" title="#{u.name.blank? ? u.login : u.name}">#{u.login.titleize}</option> \n}
    end
    select_tag('users[]', options, {:id => 'users-select', :multiple => true, :style  => "width:205px;height:84px;"})
  end

  def invitation_users_list(resource, &block)
    if resource.can_be_invited_by?(current_user) # REMOVE !
      remote_form_for(
        :invitations,
        :url => self.send("update_multiple_#{resource.class.to_s.downcase}_invitations_path", resource),
        &block
      )
    else
      block.call(:edit_mode? => false)
    end
  end

  def preview_email_url(resource)
    case resource.class.to_s
    when 'Argument'
      preview_email_argument_invitations_path(resource)
    when 'Debate'
      preview_email_debate_invitations_path(resource)
    end
  end

  def preview_email_tooltip(div_id, resource)
    <<-STR
        <script type="text/javascript">
          new Tip('#{div_id}', {
              title: 'Email preview',
              width: 500,
              closeButton: true,
              fixed: true,
              viewport: true,
              hideOn: false,
              hideAfter: 2,
              ajax: {
                  url: '#{preview_email_url(resource)}',
                  options: {
                      method: 'post',
                      parameters: {note: 'YOUR PERSONALIZED NOTE GOES HERE' }
                  }
              }
          });
        </script>
STR
  end

end
