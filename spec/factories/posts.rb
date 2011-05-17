Factory.define :post, :class => Terryblr::Post do |post|
  post.state            "published"
  post.sequence(:title) { |n| "Factory post #{n}" }
  post.published_at     1.minute.ago.to_s
  post.site_id          Terryblr::Site.default.id
  post.parts {|p| [p.association(:content_part_text)]}
  post.location_list    ["blog"]
  post.tag_list         ['test_tag', 'other_tag']
  post.author           { |author| author.association :user}
  post.tw_me            false
  post.fb_me            true
end

Factory.define :pending_post, :parent => :post, :class => Terryblr::Post do |post|
  post.state            "pending"
end

Factory.define :drafted_post, :parent => :post, :class => Terryblr::Post do |post|
  post.state            "drafted"
end

Factory.define :published_post, :parent => :post, :class => Terryblr::Post do |post|
  post.state            "published"
end

Factory.define :post_to_be_published_now, :parent => :post, :class => Terryblr::Post do |post|
  post.state            "publish_now"
end

Factory.define :photos_post, :class => Terryblr::Post do |post|
  post.post_type        "photos"
  post.sequence(:title) { |n| "Factory photos post #{n}" }
end

Factory.define :videos_post, :class => Terryblr::Post do |post|
  post.post_type        "videos"
  post.sequence(:title) { |n| "Factory videos post #{n}" }
end