Rails.application.routes.draw do
  root :to => 'terryblr/home#index'
  
  # Posts
  resources :posts, :only => [:index, :show], :member => { :gallery_params => :any, :preview => :get, :next => :get, :previous => :get }, :controller => "terryblr/posts" do
    resources :likes, :only => [:index, :create], :controller => "terryblr/likes"
    resources :comments, :only => [:index, :create, :update], :controller => "terryblr/comments"
  end
  match "/posts/tagged/:tag", :to => "terryblr/posts#tagged", :as => "tagged_posts"
  match "/posts/archives", :to => "terryblr/posts#archives", :as => "archive_posts"
  match '/posts/:id/:slug', :to => "terryblr/posts#show", :as => "post"

  # Pages
  match '/:page_slug', :to => 'terryblr/pages#show', :as => "page"

  # Search
  match '/search', :to => 'terryblr/home#search', :as => "search"

end
