class Admin::HomeController < Admin::BaseController
  before_filter :initialize_times, :except => [:instructions]
 

  #TODO refactor
  # Login statistics
  def stats
    conditions = ['created_at >= ? and created_at <= ?',@start, @stop]
    @new_users_count   = User.count(:conditions => conditions)
    @total_users_count = User.count(:all)
    @new_arguments_count = Argument.count(:conditions => conditions)
    @new_debates_count = Debate.count(:conditions => conditions)
    @new_ratings_count = Rating.count(:conditions => conditions)
    @login_totals = Login.find(:first, :select => 'SUM(duration) duration, SUM(visits) clicks',
      :conditions => conditions)
    @time_online = 0
    @logins = (Login.find(:all,:conditions => ['created_at >= ? and created_at <= ?',@start, @stop],:order => 'duration desc',:limit => 7 ))
    @unique_users = (Set.new(@logins.collect {|l| l.name})).size
    for login in  @logins
      @time_online += login.duration
    end
    
    start = @start.strftime '%Y-%m-%d'
    stop  = @stop.strftime '%Y-%m-%d'
=begin
    order = { :login     => 'l.name',
              :arguments => 'sum_of_arguments',
              :debates   => 'sum_of_debates',
              :ratings   => 'sum_of_ratings',
              :duration  => 'duration',
              :clicks    => 'visits',
              :last_seen => 'last_seen'
            }[(params[:c].blank? ? :login : params[:c].downcase.to_sym)] + ' ' + (params[:d] == 'up' ? 'ASC' : 'DESC')
    @logins = Login.paginate( :page => params[:page], :per_page => 5,
      :total_entries => Login.count_by_sql("SELECT count(DISTINCT l.name) FROM logins l
                  WHERE l.created_at >= '#{start}' and l.created_at <= '#{stop}'"),
      :select => 'l.user_id, l.name,
                  SUM(DISTINCT l.duration) as duration,
                  SUM(DISTINCT l.visits) as visits,
                  MAX(DISTINCT l.updated_at) last_seen,
                  COUNT(DISTINCT a.id) as sum_of_arguments,
                  COUNT(DISTINCT r.id) as sum_of_ratings,
                  COUNT(DISTINCT d.id) as sum_of_debates',
      :from   => 'logins l',
      :joins  => [["arguments", 'a'], ['debates', 'd'], ['ratings', 'r']].collect { |a|
            "LEFT JOIN arguments ax ON (ax.user_id = l.user_id and ax.created_at >= '#{start}' and ax.created_at <= '#{stop}')".gsub('arguments', a[0]).gsub('ax', a[1])
          }.join(' '),
      :conditions => "l.created_at >= '#{start}' and l.created_at <= '#{stop}'",
      :group => 'l.name',
      :order => order)
=end

    # Disabled joins
    order = { :login     => 'logins.name',
      :arguments => 'sum_of_arguments',
      :debates   => 'sum_of_debates',
      :ratings   => 'sum_of_ratings',
      :duration  => 'duration',
      :clicks    => 'visits',
      :last_seen => 'last_seen'
    }[(params[:c].blank? ? :login : params[:c].downcase.to_sym)] + ' ' + (params[:d] == 'up' ? 'ASC' : 'DESC')
    @logins = Login.paginate( :page => params[:page], :per_page => 5,
      :select => 'logins.user_id, logins.name,
                  SUM(DISTINCT logins.duration) as duration,
                  SUM(DISTINCT logins.visits) as visits,
                  MAX(DISTINCT logins.updated_at) last_seen,
                  0 as sum_of_arguments,
                  0 as sum_of_ratings,
                  0 as sum_of_debates',
      :conditions => "logins.created_at >= '#{start}' and logins.created_at <= '#{stop}'",
      :group => 'logins.name',
      :order => order)


    ids = @logins.collect{|l| l.user_id}.delete_if{|id| id.nil?}
    @users = {}
    User.find(:all, :conditions => ['id in (?)', ids]).each {|u| @users[u.id] = u} unless ids.empty?

    respond_to do |format|
      format.html # index.html.erb
      format.js { render :partial => (params[:usersonly] ? 'users' : 'stats') }
    end

  rescue ArgumentError => e
    render :partial => 'invalid_date_format'
  end

  # Debate statistics
  def debate_stats
    conditions = ['debates.created_at >= ? and debates.created_at <= ?',@start, @stop]

    order = { :debates    => 'debate_title',
      :arguments  => 'arguments_count',
      :ratings    => 'ratings_count',
      :updated_at => 'debate_updated_at',
      :is_live    => 'is_live',
    }[(params[:c].blank? ? :debates : params[:c].downcase.to_sym)] + ' ' + (params[:d] == 'up' ? 'ASC' : 'DESC')

    @debates = Debate.stats(params[:page] || 1, 50, conditions, order)

    respond_to do |format|
      format.html # index.html.erb
      format.js { render :partial => (params[:usersonly] ? 'debates' : 'debate_stats') }
    end

  rescue ArgumentError => e
    render :partial => 'invalid_date_format'
  end

  # Category statistics
  def category_stats
    conditions = ['categories.created_at >= ? and categories.created_at <= ?',@start, @stop]

    order = { :categories => 'categories.name',
      :debates    => 'debates_count',
      :arguments  => 'arguments_count',
      :ratings    => 'ratings_count',
      :updated_at => 'categories.updated_at'
    }[(params[:c].blank? ? :categories : params[:c].downcase.to_sym)] + ' ' + (params[:d] == 'up' ? 'ASC' : 'DESC')

    @categories = Category.stats(params[:page] || 1, 50, conditions, order)

    respond_to do |format|
      format.html # index.html.erb
      format.js { render :partial => (params[:usersonly] ? 'categories' : 'category_stats') }
    end

  rescue ArgumentError => e
    render :partial => 'invalid_date_format'
  end

  def support_pages
     @support_pages = SupportPage.find(:all)
  end

  # Admin Instructions Page
  def instructions
  end


  def ratings_graph       
    @clarity = open_flash_chart_object(500,250, "/home/clarity/#{params[:id]}")
    @relevance  = open_flash_chart_object(500,250, "/home/relevance/#{params[:id]}")
    @accuracy  = open_flash_chart_object(500,250, "/home/accuracy/#{params[:id]}")
  end
  
  def clarity   
    bar = Bar.new(50, '#0066CC')
    @ratings = Rating.find(:all,:select =>"count(user_id) as total_users , clarity" , :conditions => ['argument_id = ?', params[:id]],:group => 'clarity' , :order => 'clarity')
    @ratings.each do |t|
      bar.data << t.total_users
    end
    g = Graph.new
    g.title("Clarity", "{font-size: 26px;}")
    g.data_sets << bar
    g.set_x_labels(@ratings.collect{|r|r.clarity})
    graph_settings(g)    
  end  
  def relevance  
    bar = Bar.new(50, '#0066CC')
    @ratings = Rating.find(:all,:select =>"count(user_id) as total_users , relevance" , :conditions => ['argument_id = ?', params[:id]],:group => 'relevance' , :order => 'relevance')
    @ratings.each do |t|
      bar.data << t.total_users
    end
    g = Graph.new
    g.title("Relevance", "{font-size: 26px;}")
    g.data_sets << bar
    g.set_x_labels(@ratings.collect{|r|r.relevance})
    graph_settings(g)
  end
  def accuracy  
    bar = Bar.new(50, '#0066CC')
    @ratings = Rating.find(:all,:select =>"count(user_id) as total_users , accuracy" , :conditions => ['argument_id = ?', params[:id]],:group => 'accuracy' , :order => 'accuracy')
    @ratings.each do |t|
      bar.data << t.total_users
    end
    g = Graph.new
    g.title("Accuracy", "{font-size: 26px;}")
    g.data_sets << bar
    g.set_x_labels(@ratings.collect{|r|r.accuracy})
    graph_settings(g)
  end

  def graph_settings(graph)    
    graph.set_x_label_style(10, '#9933CC', 0, 1)
    graph.set_x_axis_steps(10)
    graph.set_y_max(40)
    graph.set_y_label_steps(10)
    graph.set_y_legend("#rating", 12, "0x736AFF")
    graph.set_x_legend("Rating", 12, "0x736AFF")
    render :text => graph.render
  end
  def ratings
    @argument = Argument.find(:first , :conditions => ['id = ?', params[:id]])
    order_by = 'users.login'
    if ['username_id', 'fullname_id'].include?(params[:c])
      order_by = (params[:c] == 'username_id') ? 'users.login' : 'users.name'
    end
    
    order_by  += (params[:d] == 'up') ? ' ASC' : ' DESC'     
    
    @ratings = Rating.paginate(:page => params[:page], :per_page => 25,:include => [:user] ,:conditions => ["argument_id = ? ", params[:id]], :order => order_by)
    
  end
  
  private 

  # Initialize times to be able to use them later
  def initialize_times
    if (spec = params[:time_spec])
      @start = Date.parse(spec[:start_time])
      @stop  = Date.parse(spec[:stop_time]) + 1.day - 1.minute
    else
      @start = (Date.parse(params[:start_time]) rescue Date.new(1970) )#today - 1.week)
      @stop  = (Date.parse(params[:stop_time])  rescue Date.today + 1.day)
    end
  end
end
