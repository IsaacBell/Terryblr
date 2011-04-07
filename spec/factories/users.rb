Factory.sequence :email do |n|
  "user#{n}@example.com"
end

Factory.define :user, :class => Terryblr::User do |user|
  user.email                  { Factory.next :email }
  user.first_name             "john"
  user.last_name              "doe"
  user.admin                  false
  user.created_at             5.days.ago
  user.updated_at             5.days.ago
  user.password               "gayfish"
  user.password_confirmation  "gayfish"
  # user.remember_token       
  # user.remember_created_at  
  # user.sign_in_count        
  # user.current_sign_in_at   
  # user.last_sign_in_at      
  # user.current_sign_in_ip   
  # user.last_sign_in_ip      
end

Factory.define :admin, :parent => :user, :class => Terryblr::User do |user|
  user.admin true
end