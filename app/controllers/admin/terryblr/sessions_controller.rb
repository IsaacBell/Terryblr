class Admin::Terryblr::SessionsController < Devise::SessionsController
  
  layout 'admin'
  helper 'devise', 'terryblr/admin', 'terryblr/application'
  
end