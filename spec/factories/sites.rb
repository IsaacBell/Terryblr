Factory.define :site, :class => Terryblr::Site do |site|
  site.sequence(:name)  { |n| "site-#{n}" }
  site.created_at          5.minutes.ago
  site.updated_at          5.minutes.ago
end