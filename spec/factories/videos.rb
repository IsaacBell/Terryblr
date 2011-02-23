Factory.define :video, :class => Video do |video|
  video.sequence(:caption)  { |n| "Factory video #{n}" }
  video.url                 "http://test.host/test.url"
  video.vimeo_id            "url4test"
  video.created_at          5.minutes.ago
  video.updated_at          5.minutes.ago
  video.sequence(:display_order)  { |n| n }
  video.embed               "http://vimeo.com/moogaloop.swf"
  video.width               360
  video.height              240
  video.thumb_url           "http://test.host/test_thumb.url"
end