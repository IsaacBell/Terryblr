Rails.application.routes.draw do
  namespace :terryblr do
    resources :pages, :only => [:show]
  end
end
