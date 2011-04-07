Factory.define :page, :class => Terryblr::Page do |page|
  page.sequence(:title)     { |n| "Factory page #{n}" }
  page.sequence(:slug)      { |n| "factory-page-#{n}" }
  page.body                 "<p>I'm a simple body</p>"
  page.state               "published"
  page.parent_id            nil
  page.sequence(:position)  { |n| n }
  page.post_id              nil
  page.site_id              Terryblr::Site.default.id
end

Factory.define :pending_page, :parent => :page, :class => Terryblr::Page do |page|
  page.state                "pending"
end

Factory.define :drafted_page, :parent => :page, :class => Terryblr::Page do |page|
  page.state                "drafted"
end

Factory.define :published_page, :parent => :page, :class => Terryblr::Page do |page|
  page.state                "published"
end
