Factory.define :user, :class => Terryblr::User do |user|
  user.sequence(:email)      { |n| "user-#{n}@test.com" }
  user.first_name            "Mr"
  user.last_name             "Tester"
  user.password              "secretpassword"
  user.password_confirmation "secretpassword"
end

Factory.define :user_admin, :parent => :user, :class => Terryblr::User do |user|
  user.first_name            "Admin"
  user.last_name             "Tester"
  user.admin                 true
end
