Factory.define :post, :class => Terryblr::Post do |post|
  post.state            "published"
  post.post_type        "post"
  post.sequence(:title) { |n| "Factory post #{n}" }
  post.body             "<h1>I'm a simple body</h1>"
  post.published_at     1.minute.ago
  post.display_type     "gallery"
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