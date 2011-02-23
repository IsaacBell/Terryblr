Rails.application.routes.draw do
  root :to => "terryblr/home#index"
  
  match "/admin", :to => "terryblr/admin#index", :as => "admin"
  match "/admin/search", :to => "terryblr/admin#search", :as => :admin_search
  match '/admin/analytics.:format', :to => "terryblr/admin#analytics", :as => :admin_analytics
  namespace :admin do
    resources :posts, :controller => "terryblr/posts" do
      collection do
        get  :filter
        post :filter
      end
      resources :comments, :except => [:new, :create], :controller => "terryblr/comments"
      resources :links, :controller => "terryblr/links"
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
    resources :orders
    resources :products
    resources :pages
    resources :users do
      collection do
        get :admins
      end
    end
    match "/logout", :to => "todoadmin#index"

    %w(page product user).each do |p|
      match "new/#{p}", :to => "terryblr/#{p.pluralize}#new"
    end
    match "new/feature", :to => "todoadmin#index", :as => :new_content
    match "new/:type", :to => "terryblr/posts#new", :as => :new_content
  end

  match "/store", :to => "terryblr/products#show", :as => "store"
  match "/store/products/tagged/:tag", :to => "terryblr/products#tagged", :as => "store_tagged_products"
  resource :cart, :only => [:show], :member => { :checkout => :any }, :path_prefix => "/store", :controller => "terryblr/cart"
  match "/products/:id/:slug", :to => "terryblr/products#show", :as => "product"
  resources :products, :member => { :gallery_params => :any, :next => :get, :previous => :get }, :path_prefix => "/store", :controller => "terryblr/products" do
    resource :cart, :only => [:create, :update, :destroy], :controller => "terryblr/cart"
  end
  resources :orders, :only => [:index, :show], :path_prefix => "/store", :controller => "terryblr/orders"

  # Posts (be carefull, order matters!)
  match "/posts/tagged/:tag", :to => "terryblr/posts#tagged", :as => "tagged_posts"
  match "/posts/archives", :to => "terryblr/posts#archives", :as => "archive_posts"
  resources :posts, :only => [:index, :show], :member => { :gallery_params => :any, :preview => :get, :next => :get, :previous => :get }, :controller => "terryblr/posts" do
    resources :likes, :only => [:index, :create], :controller => "terryblr/likes"
    resources :comments, :only => [:index, :create, :update], :controller => "terryblr/comments"
  end
  match "/posts/:id/:slug", :to => "terryblr/posts#show", :as => "post"

  # Search
  match "/search", :to => "terryblr/home#search", :as => "search"

  # Robots.txt
  match "/robots.txt", :to => "terryblr/home#robots", :format => "txt"

  # Error Pages
  match "/500", :to => "terryblr/home#error", :as => "error"
  match "/404", :to => "terryblr/home#not_found", :as => "not_found"

  # Pages (MUST be last)
  match "/:page_slug", :to => "terryblr/pages#show", :as => "page"
end
