Rails.application.routes.draw do
  root :to => 'terryblr/home#index'
  
  match '/admin', :to => "terryblr/admin#index"
  namespace :admin do
    resources :posts
    resources :comments
    resources :orders
    resources :products
    resources :pages
    resources :users do
      collection do
        get :admins
      end
    end
    match "/admin/feature", :to => "todoadmin#index", :as => :new_content
    match "/admin/search", :to => "terryblr/admin#search", :as => :search
    match "/logout", :to => "todoadmin#index"
  end
  
  # Posts (be carefull, order matters!)
  match '/posts/tagged/:tag', :to => 'terryblr/posts#tagged', :as => 'tagged_posts'
  match '/posts/archives', :to => 'terryblr/posts#archives', :as => 'archive_posts'
  resources :posts, :only => [:index, :show], :member => { :gallery_params => :any, :preview => :get, :next => :get, :previous => :get }, :controller => 'terryblr/posts' do
    resources :likes, :only => [:index, :create], :controller => 'terryblr/likes'
    resources :comments, :only => [:index, :create, :update], :controller => 'terryblr/comments'
  end
  match '/posts/:id/:slug', :to => 'terryblr/posts#show', :as => 'post'

  # Search
  match '/search', :to => 'terryblr/home#search', :as => 'search'

  # Robots.txt
  match '/robots.txt', :to => 'terryblr/home#robots', :format => 'txt'

  # Error Pages
  match '/500', :to => 'terryblr/home#error', :as => 'error'
  match '/404', :to => 'terryblr/home#not_found', :as => 'not_found'
  
  # Pages (MUST be last)
  match '/:page_slug', :to => 'terryblr/pages#show', :as => 'page'
end
