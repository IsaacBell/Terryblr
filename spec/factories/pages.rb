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
