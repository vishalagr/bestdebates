class SupportController < ApplicationController
  layout "application"
  before_filter :admin_required , :only => [:new, :create , :edit, :update, :destroy]
  caches_page   :project_renovation
  def index
    @title = "Support"
    # render :text => "support" and return
  end

  def new
    @support_page = SupportPage.new
  end

  def create
    redirect_to(admin_support_pages_url) and return if params['cancel.x']
    @support_page = SupportPage.new(params[:support_page])
    flash_success = 'Support Page has been saved successfully.'
    flash_error   = 'Can\'t create a new support page'
    if @support_page.save
      flash[:notice]     = flash_success;
      redirect_to page_url(:action_page => @support_page.page_title)
    else
      flash[:notice]     = flash_error;
      render :action   => 'new'
    end
  end

  def edit
    @support_page = SupportPage.find(params[:id])
  end

  def update
    redirect_to(admin_support_pages_url) and return if params['cancel.x']
    @support_page = SupportPage.find(params[:id])
   if @support_page.update_attributes(params[:support_page])
      flash[:notice]     = 'Support Page has been updated successfully.'
    redirect_to page_url(:action_page => @support_page.page_title)
   else
      flash[:notice]     = 'Can\'t update support page'
      render :action   => 'edit'
   end
  end

  def destroy
    @support_page = SupportPage.find(params[:id])
    if @support_page.destroy
      flash[:notice]     = 'Support Page has been deleted successfully.'
    end
    redirect_to(admin_support_pages_url)
  end
  
  def principles
    
  end
  
  def project_renovation

  end
  
  
  def page
    @support_page = SupportPage.find(:first , :conditions => ["page_title = ? ", params[:action_page]])
    if @support_page.blank?
      redirect_to(root_url)
    end
  end
  
  def participate
    
  end
end
