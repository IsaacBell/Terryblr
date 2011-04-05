Factory.define :feature, :class => Terryblr::Feature do |feature|
  feature.sequence(:title)  { |n| "Factory feature #{n}" }
  feature.sequence(:display_order)  { |n| n }
  feature.association :post, :factory => :photos_post
  feature.created_at          5.minutes.ago
  feature.updated_at          5.minutes.ago
  feature.tag_list            %w(home)
end