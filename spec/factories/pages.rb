Factory.define :page, :class => Terryblr::Page do |page|
  page.sequence(:title)     { |n| "Factory page #{n}" }
  page.sequence(:slug)      { |n| "factory-page-#{n}" }
  page.body                 "<h1>I'm a simple body</h1>"
  page.state               "published"
  page.parent_id            nil
  page.sequence(:position)  { |n| n }
  page.post_id              nil
end
