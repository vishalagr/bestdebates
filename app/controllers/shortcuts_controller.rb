class ShortcutsController < ApplicationController


  def shortcut
   case params[:resource]
     when 'd'
	debt = Debate.find_by_id(params[:action_page].to_i)
	if !debt.blank?
       	 redirect_to debate_url(params[:action_page])
	else
	 flash[:notice] = "Unable to find the debate or debate doesn't exists"
       	 redirect_to debates_url
	end
     when 'i'
       shtcut = Shortcut.find_by_resource_name(params[:action_page])
       if !shtcut.blank?
        redirect_to shtcut.resource_url
       else
         redirect_to root_url
        end
     when 'a'
	arg = Argument.find_by_id(params[:action_page].to_i)
       if !arg.blank?
 	      redirect_to argument_url(params[:action_page])
	else
 	      flash[:notice] = "Unable to find the argument or argument doesn't exists "
 	      redirect_to root_url   
	end
     else
	flash[:notice] = "Unable to find the url"
	redirect_to root_url
     end
  end

end
