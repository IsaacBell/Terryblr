Factory.define :content_part, :class => Terryblr::ContentPart do |post|
  post.content_type     "text"
  post.body             "<p>I'm a simple body</p>"
  post.display_type     ""
  post.sequence(:display_order) { |n| n }
end
