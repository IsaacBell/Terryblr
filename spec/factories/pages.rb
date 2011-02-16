Factory.define :page, :class => Terryblr::Page do |page|
  page.sequence(:title)     { |n| "Factory page #{n}" }
  page.body                 "<h1>I'm a simple body</h1>"
  page.published_at         Time.now
#  page.state               "pending"
  page.parent_id            nil
  page.sequence(:position)  { |n| n }
  page.post_id              nil
end