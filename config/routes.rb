ActionController::Routing::Routes.draw do |map|
 

  

  #Jammit::Routes.draw(map)
  
  map.resources :groups do |g|
    g.resources :members    
  end
  map.resources :search_results, :controller => 'search'
  
  map.with_options :controller => 'sessions' do |sessions|
    sessions.logout '/logout', :action => 'destroy'
    sessions.login  '/login',  :action => 'new'

    map.resource  :session, :only => [:new, :create]
    sessions.open_id_complete 'session', :action => "create", :requirements => {:method => :get}
  end
  
  map.tree   '/tree',  :controller => 'tree', :action => 'index' # TODO recheck the action
  map.resource :api_key
  
  map.with_options :controller => 'users' do |users|
    users.register '/register', :action => 'create'
    users.signup   '/signup',   :action => 'new'
    users.forgot_password '/forgot_password', :action => 'forgot_password'
    users.reset_password  '/reset_password/:activation_code', :action => 'reset_password'
    
    # TODO move to resource's collection
    users.link_accounts '/users/link_user_accounts', :action => 'link_user_accounts'

    users.activate     '/activate/:activation_code',       :action => 'activate', :activation_code => nil
  end  
  map.resources :users, :except => :index, :member => {:change_password => :get, :edit_password => :post,:updatebookmark=>:post, :tooltip => :get,:bookmark_text=>:get,:watching => :put, :auto_tweet => :get,:auto_tweet_edit => :get,:auto_tweet_update => :any , :auto_tweet_create => :post}, :collection => {:users_search => :get,:message_users_mails => :get}
  map.editbookmark 'user/editbookmark/:id' , :controller => 'users' , :action => 'editbookmark'
  map.support '/support', :controller =>'support' , :action =>'index'
  map.principles '/support/principles' , :controller =>'support' , :action => 'principles'
  map.participate '/support/participate1', :controller => 'support' , :action => 'participate'
  map.project_renovation '/support/project_renovation', :controller => 'support' , :action => 'project_renovation'
#  map.contest 'support/page/Cannabis_Contest', :controller => 'support' , :action => 'cannabis_contest'
  map.firefox_login '/firefox_login' , :controller => 'home', :action => 'firefox_login'
  map.firefox_logout '/firefox_logout' , :controller => 'home', :action => 'firefox_logout'
  map.ff_welcome_page '/ff_welcome_page' , :controller => 'home' , :action => 'ff_welcome_page'
  map.ff_feedback_page '/ff_feedback_page' , :controller => 'home' , :action => 'ff_feedback_page'
  
  map.namespace :admin do |admin|
    admin.categories_update 'categories/update', :controller => 'categories', :action => 'update', :conditions => {:method => :post} # TODO remove after rails update
    admin.resources :categories,    :except => [:show,   :edit  ], :collection => {:debate_of_day => :any}# + {:update => :post} TODO uncomment after rails update
    admin.resources :definitions,   :only   => [:index,  :create]
    admin.resources :tags,          :except =>  :show, :collection => [:cloud]
    admin.resources :twitter_accounts , :member => [:twitter_debate_create => :post]
    admin.resources :debates,       :only   => [], :collection => {:manage => :post}, :member => {:unretire => :get,:debate_live_stat=>:get}
    admin.resources :groups,        :except => [:edit,   :update, :destroy] do |g|
      g.resources   :members
    end
    admin.resources :variables, :member => {:activate => :get}
    admin.resources :rating_variables, :member => {:activate => :get}
    admin.resources :user_variables, :member => {:activate => :get}
    admin.resources :shortcuts
    admin.resources :users,    :collection => {:search => :any}, :member => {:purge => :get, :drop => :get, :view => :get}
    admin.home     ':action',  :controller => 'home', :action => 'stats'
  end

  
  map.admin_support_pages 'admin/support_pages' , :controller => 'admin/home' , :action => 'support_pages'
  map.debate_live_stat 'admin/debate/debate_live_stat/:id' , :controller =>"admin/debates",:action => "debate_live_stat"
  #map.debate_live_stat 'admin/home/debate_live_stat/:id' , :controller =>"admin/home",:action => "debate_live_stat"
  map.namespace :facebook, :name_prefix => 'fb_' do |fb|
    fb.profile_publisher 'profile_publisher', :controller => 'profile_publisher', :action => 'index'
    fb.my_debates 'debates/mine',             :controller => 'debates',           :action => 'mine'
    fb.my_argument 'arguments/:id' , :controller => 'debates', :action => 'show'
  end
   map.manage_twitter_accounts 'manage_twitter_accounts/admin' , :controller => 'admin/twitter_accounts' , :action => 'manage_twitter_accounts'
   map.category_twitter_accounts 'category_twitter_accounts/admin' , :controller => 'admin/twitter_accounts' , :action => 'category_twitter_accounts'
   map.debate_twitter_create 'debate_twitter_create/admin', :controller => 'admin/twitter_accounts' , :action => 'twitter_debate_create'
   map.category_twitter_create 'category_twitter_create/admin', :controller => 'admin/twitter_accounts' , :action => 'twitter_category_create'
   map.connect '/addon' , :controller => "home", :action => "addon"
  # map.connect '/chrome' , :controller => "home", :action => "chrome" #chrome route
   map.firefox '/firefox' , :controller => "home", :action => "firefox"
   map.contact '/contact', :controller => "home",:action =>"contact"
   map.connect     "logged_exceptions/:action/:id", :controller => "logged_exceptions"
   map.islogged '/islogged' , :controller => "home" , :action => "logged_user"
  #TODO move in debates
  map.resources :arguments, :member => {:move         => :get,
                                        :tooltip      => :any,
                                        :watching => :any,
                                        :search_tooltip => :any,
                                        :drafts_tooltip => :any,
                                        :rating       => :any,
                                        :add_tag      => :put,
                                        :publish      => :get,
                                        :unpublish    => :get,
                                        :send_email   => :post,
                                        :temp_arg_edit => :any ,
                                        :update_temp_argument => :any ,
                                        :large_image => :get,
                                        :firefox_argument_show => :get,
                                        :firefox_delete => :delete,
                                        :forgot_password => :post,
                                        :reset_password  => :get,
                                        :bookmark        => :post,
                                        :unbookmark      => :post,
                                        :bookmark_from_email => :get,
                                        :report_offensive => :post,
                                        :relations => :post,                                        
                                        :duplicate_argument => :post
                                       } do |args|
   args.resources :links, :controller => 'argument_links', :only => [:destroy, :create]
   args.resources :invitations, :collection => {:update_multiple => :post,
                                                :preview_email => :post
                              }, :member => {:resend_email => :post}
   args.resources :invite_links, :only => [:index, :new, :create], :member => {:invited_users => :post}
 end

  map.user_debate_stat 'admin/user/debate_state/:id' , :controller => 'debates' , :action => "debate_state"
  map.resources(
   :private_messages, :controller => 'PrivateMessages',
    :member => { :markread => :put, :markunread => :put },
    :collection => { :reply => :post }
  )
  map.addon_argument_create 'arguments/addon_argument_create' , :controller => 'arguments',:action => 'addon_argument_create'
  #map.chrome_argument_create 'arguments/chrome_argument_create' , :controller => 'arguments',:action => 'chrome_argument_create' #chrome route
  map.argument_rss_link '/arguments/:id/rss/deep/:deep.xml', :controller => 'arguments', :action => 'rss'
  map.argument_tab      '/arguments/:id/tabs/:tab',          :controller => 'arguments', :action => 'tab'
  map.ratings 'admin/ratings/:id' , :controller =>'admin/home' ,:action => 'ratings'
  map.debate_with_icode   '/debates/:id/code/:code',         :controller => 'debates', :action => 'show'
  map.debate_with_invlink '/debates/:id/invlink/:unique_id', :controller => 'debates', :action => 'show'
  map.all_arguments_ratings '/admin/ratings/graph/:id' , :controller =>"admin/home" , :action => 'ratings_graph'
  map.graph_clarity '/home/clarity/:id' , :controller => "admin/home" , :action => 'clarity'
  map.graph_relevance '/home/relevance/:id' , :controller => "admin/home" , :action => 'relevance'
  map.graph_accuracy '/home/accuracy/:id' , :controller => "admin/home" , :action => 'accuracy'
  map.argument_with_icode   '/arguments/:id/code/:code',         :controller => 'arguments', :action => 'show'
  map.argument_with_invlink '/arguments/:id/invlink/:unique_id', :controller => 'arguments', :action => 'show'
  map.unsubscription '/argument/unsubscription/:activation_code' , :controller => 'arguments' , :action => 'unsubscription'
  map.resources :debates, :member => {:tooltip  => :any,
                                      :rate     => :post,
                                      :watching => :any,
                                      :add_tag  => :put,
                                      :bookmark => :post,
                                      :unbookmark     => :post,
                                      :send_email   => :post,
                                      :report_offensive => :post,
									                    :update_invitations => :any
                                     },
                          :collection => {:auto_complete_for_debate_title => :post,
                                          :search => :get} do |debate|
#                                     }, :collection => {:auto_complete => :post} do |debate|
    debate.resources :invitations, :collection => { :update_multiple => :post,
                                                    :preview_email => :post
                                }, :member => {:resend_email => :post}
    debate.resources :invite_links, :only => [:index, :new, :create], :member => {:invited_users => :post}

   debate.resources :arguments,
      :member     => {:rate => :post},
      :collection => { :xml_import   => :post, :similar_argument => :post }

	end
  map.resources :support_pages , :controller=>'support' 
  map.page 'support/page/:action_page' , :controller => 'support' , :action => 'page'
  map.debate_rss_link '/debates/:id/rss/deep/:deep.xml', :controller => 'debates', :action => 'rss'
  map.debate_tab      '/debates/:id/tabs/:tab',            :controller => 'debates', :action => 'tab'
   
  map.root :controller => 'facebook/my_facebook', :action => 'index', :conditions => {:canvas => true}
  map.root :controller => 'home',                 :action => 'index'
  map.shortcut ':resource/:action_page' , :controller => 'shortcuts' , :action => 'shortcut'

end
