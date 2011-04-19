Factory.define :post, :class => Terryblr::Post do |post|
  post.state            "published"
  post.post_type        "post"
  post.sequence(:title) { |n| "Factory post #{n}" }
  post.body             "<p>I'm a simple body</p>"
  post.published_at     1.minute.ago.to_s
  post.display_type     "gallery"
  post.site_id          Terryblr::Site.default.id
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