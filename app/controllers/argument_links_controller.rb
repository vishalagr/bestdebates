# Argument links are links/urls stored for each argument
# an +argument+ can have many +argument_links+
class ArgumentLinksController < ApplicationController
  before_filter :login_required
  before_filter :find_argument
    
  with_options :xhr => true, :redirect_to => :debates_url do |v|
    v.verify :method => :post,   :only => :create
    v.verify :method => :delete, :only => :destroy
  end
  
  # Create the argument_link
  def create
    if can_edit_argument?(@argument)
      @argument_link = @argument.links.build(params[:link])
      flash.now[:error] = @argument_link.errors.full_messages.join('<br />') unless @argument_link.save
    else
      @argument_link = nil
      flash.now[:error] = 'You don\'t have permissions to edit this argument'
    end
  end
  
  # Destroy the argument_link
  def destroy
    @argument_link = @argument.links.find(params[:id])
    @argument_link.destroy
    flash.now[:notice] = 'The link was removed'
  end
end
