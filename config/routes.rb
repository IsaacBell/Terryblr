Rails.application.routes.draw do |map|
  namespace :terryblr do
    resources :accounts, :only => [:new]
  end
end
