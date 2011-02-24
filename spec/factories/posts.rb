Factory.define :post, :class => Post do |post|
  post.post_type        "post"
  post.sequence(:title) { |n| "Factory post #{n}" }
  post.body             "<h1>I'm a simple body</h1>"
  post.published_at     1.minute.ago
  post.display_type     "gallery"
end