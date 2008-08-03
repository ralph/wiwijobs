ActionController::Routing::Routes.draw do |map|
  map.resources :rights, :roles, :categories

  map.resource :session
  map.resources :job_links, :collection => { :list => :get }
  map.resources :news_items, :collection => { :internal => :get, :job => :get, :list => :get }
  map.resources :users, :new => { :update_user_type_specific_fields => :post }, :collection => { :students => :get }
  map.resources :jobs, :member => { :publish => :put, :unpublish => :put }, :collection => { :list => :get, :list_degree => :get, :list_intern => :get , :list_graduate => :get, :list_student => :get,  :home => :get }
  map.resources :job_events, :collection => { :list => :get }

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.
  map.index '', :controller => "jobs", :action => "home"
  map.legal '/impressum', :controller => "jobs", :action => "impressum"
  map.contact '/contact', :controller => "jobs", :action => "contact"
  map.textilize '/textilize', :controller => "auxiliary", :action => "textilize"

  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.reset_password '/reset_password', :controller => 'users', :action => 'reset_password'
  map.admin '/admin', :controller => "users", :action => "homepage"
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  # map.connect ':controller/:action/:id.:format'
  # map.connect ':controller/:action/:id'
end
