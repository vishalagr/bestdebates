class Admin::DefinitionsController < Admin::BaseController
  make_resourceful do
		actions :edit, :update, :destroy
		
		response_for :update do |format|
			format.html { redirect_to admin_definitions_path }
		end
    
		response_for :destroy do |format|
      format.html { flash[:notice] = 'Definition was successfully deleted.'; redirect_to admin_definitions_path }
		end
	end
  
  # List of definitions
  def index
    @definitions = Definition.paginate :page => params[:page], :per_page => 20
    @definition  = Definition.new
  end
  
  # Create a definition
  def create
    definition = Definition.create(params[:definition])
    notice = definition.errors.empty? ? 'Definition was successfully created.' : 'Can not created'
    respond_to do |format|
      format.js do
        render :update do |page|
          if definition.errors.empty?
            page.replace_html 'definitions', render(:partial => 'definitions', :locals => {:definitions => Definition.all})
          else
            definition.errors.each {|error| notice << '<br />' + error.class}
          end
          page.replace_html 'notice', notice
          page.visual_effect :appear,    'notice', :duration => 5.0
          page.visual_effect :highlight, 'notice', :duration => 5.0
          page.visual_effect :fade,      'notice', :duration => 5.0
        end
      end

      format.html do
        redirect_to admin_definitions_url
        flash[:notice] = notice
      end
    end
  end  
end
