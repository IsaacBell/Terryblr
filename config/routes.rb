
Rails.application.routes.draw do
  root :to => "terryblr/home#index"

  begin
    devise_for :users, :class_name => "Terryblr::User", :path => "admin", :controllers => { :sessions => "admin/terryblr/sessions" }, :path_names => { :sign_in => 'login', :sign_out => 'logout' }
  rescue ActiveRecord::StatementInvalid => e
    puts "Devise could not be set up for the user model."
    puts "Please make sure you have run 'rake terryblr:install:migrations' and run any pending migrations."
    puts "Original exception: #{e.class}: #{e}"
  end
  match "/admin", :to => "terryblr/admin#index", :as => "user_root" # Redirect to after login

  match "/admin", :to => "terryblr/admin#index", :as => "admin"
  match "/admin/search", :to => "terryblr/admin#search", :as => :admin_search
  match '/admin/analytics.:format', :to => "terryblr/admin#analytics", :as => :admin_analytics
  namespace :admin do
    resources :posts, :controller => "terryblr/posts" do
      collection do
        match ':state/:month/:year(.:format)', :to => "terryblr/posts#filter", :as => :drafted, :constraints => { :state => /(drafted|published)/, :year => /\d{4}/, :month => /\d{1,2}/ }
        get  :filter
        post :filter
      end
      # resources :comments, :except => [:new, :create], :controller => "terryblr/comments"
      # resources :links, :controller => "terryblr/links"
      resources :videos, :controller => "terryblr/videos"
      resources :photos, :controller => "terryblr/photos"
    end
    resources :features, :controller => "terryblr/features" do
      collection do
        get  :filter
        post :filter
        post :reorder
      end
      resource :photo, :controller => "terryblr/photo"
    end
    resources :comments
    resources :videos, :only => [:index, :destroy], :controller => "terryblr/videos" do
      post :reorder, :on => :collection
    end
    resources :photos, :only => [:index, :destroy], :controller => "terryblr/photos" do
      post :reorder, :on => :collection
    end
    resources :pages, :controller => "terryblr/pages" do
      resources :messages, :only => [:index, :show, :delete], :controller => "terryblr/messages"
      resources :photos, :controller => "terryblr/photos"
    end
    # resources :orders
    # resources :products
    resources :users, :controller => "terryblr/users" do
      collection do
        get :admins
      end
    end

    %w(page product user).each do |p|
      match "new/#{p}", :to => "terryblr/#{p.pluralize}#new"
    end
    match "new/feature", :to => "terryblr/features#new", :as => :new_content
    resources :features, :collection => {:filter => :any, :reorder => :post}, :controller => "terryblr/features" do
      resource :photo, :controller => "terryblr/photos"
    end
    match "new/:type", :to => "terryblr/posts#new", :as => :new_content
  end

  # match "/store", :to => "terryblr/products#show", :as => "store"
  # match "/store/products/tagged/:tag", :to => "terryblr/products#tagged", :as => "store_tagged_products"
  # resource :cart, :only => [:show], :member => { :checkout => :any }, :path_prefix => "/store", :controller => "terryblr/cart"
  # match "/products/:id/:slug", :to => "terryblr/products#show", :as => "product"
  # resources :products, :member => { :gallery_params => :any, :next => :get, :previous => :get }, :path_prefix => "/store", :controller => "terryblr/products" do
  #   resource :cart, :only => [:create, :update, :destroy], :controller => "terryblr/cart"
  # end
  # resources :orders, :only => [:index, :show], :path_prefix => "/store", :controller => "terryblr/orders"

  # Posts (be carefull, order matters!)
  match "/posts/tagged/:tag", :to => "terryblr/posts#tagged", :as => "tagged_posts"
  match "/posts/archives", :to => "terryblr/posts#archives", :as => "archive_posts"
  resources :posts, :only => [:index, :show], :controller => "terryblr/posts" do
    member do
      get :gallery_params
      get :preview
      get :next
      get :previous
    end
    # resources :likes, :only => [:index, :create], :controller => "terryblr/likes"
    # resources :comments, :only => [:index, :create, :update], :controller => "terryblr/comments"
  end
  match "/posts/:id/:slug", :to => "terryblr/posts#show", :as => "post"

  # Search
  match "/search", :to => "terryblr/home#search", :as => "search"

  # Sitemap.xml
  match "/sitemap.xml", :to => "terryblr/home#sitemap", :format => "xml"

  # Robots.txt
  match "/robots.txt", :to => "terryblr/home#robots", :format => "txt"

  # Error Pages
  match "/500", :to => "terryblr/home#error", :as => "error"
  match "/404", :to => "terryblr/home#not_found", :as => "not_found"

  # Pages (MUST be last)
  match "/:page_slug", :to => "terryblr/pages#show", :as => "page"
end
