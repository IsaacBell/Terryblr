Rails.application.routes.draw do
  namespace :terryblr do
    resources :pages, :only => [:show]
    resources :posts, :only => [:index]
  end
end
