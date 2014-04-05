class Admin::TagsController < Admin::BaseController  

  make_resourceful do
		actions :new, :create, :edit, :update
	end
  
  # List of tags
  def index
    calc_order
    @tag  = Tag.new

    @tags = Tag.paginate(
      :page     => params[:page] || 1,
      :per_page => 24,
      :order    => "name #{@order_name}"
    )
  end
  
  # Tag cloud
  def cloud
    calc_order
    @tag = Tag.new
    tag_cloud
  end

  # Destroy the tag
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    flash[:notice] = 'Tag was deleted'
    
    redirect_to admin_tag_path
  end

  # initialize order_by and order
  def calc_order
    @order_by = (['name', 'popularity'].include?(params[:order_by]) ? params[:order_by] : 'popularity')

    order = (params[:order_name] or '').upcase
    @order_name = (!order.blank? and ['ASC', 'DESC'].include?(order)) ? order : 'ASC'

    order = (params[:order_popularity] or '').upcase
    @order_popularity = (!order.blank? and ['ASC', 'DESC'].include?(order)) ? order : 'ASC'
  end

  # Get tag cloud
  def tag_cloud
    if @order_by == 'name'
      @tags = if (@order_name == 'ASC')
                Tag.counts.sort {|a,b| a.name.downcase <=> b.name.downcase}
              else
                Tag.counts.sort {|a,b| b.name.downcase <=> a.name.downcase}
              end
    else
      @tags = if (@order_popularity == 'ASC')
                Tag.counts.sort {|a,b| a.count <=> b.count}
              else
                Tag.counts.sort {|a,b| b.count <=> a.count}
              end
    end
  end
end
