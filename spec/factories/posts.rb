Factory.define :post, :class => Terryblr::Post do |post|
  post.state            "published"
  post.sequence(:title) { |n| "Factory post #{n}" }
  post.published_at     1.minute.ago.to_s
  post.site_id          Terryblr::Site.default.id
  post.parts {|p| [p.association(:content_part_text)]}
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