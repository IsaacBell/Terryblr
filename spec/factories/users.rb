Factory.define :user, :class => Terryblr::User do |user|
  user.sequence(:email)      { |n| "user-#{n}@test.com" }
  user.first_name            "Mr"
  user.last_name             "Tester"
  user.password              "secretpassword"
  user.password_confirmation "secretpassword"
end

Factory.define :user_admin, :class => Terryblr::User do |user|
  user.sequence(:email)      { |n| "admin-#{n}@test.com" }
  user.first_name            "Admin"
  user.last_name             "Tester"
  user.password              "secretpassword"
  user.password_confirmation "secretpassword"
  user.admin                 true
end
