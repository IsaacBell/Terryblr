Rails.application.routes.draw do
  namespace :terryblr do
    resources :pages, :only => [:show]
    resources :posts, :only => [:index]
  end

  #Not implemented yet
  match "/cart" => "todo#index"
  match "/search" => "todo#index"
  match "/store" => "todo#index"

  root :to => "todo#index"
end
