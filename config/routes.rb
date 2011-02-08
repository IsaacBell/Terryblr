Rails.application.routes.draw do
  namespace :terryblr do
    resources :accounts, :only => [:new, :create]
  end
end
