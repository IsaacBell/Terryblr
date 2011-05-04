module Admin::Terryblr::PostsHelper

  def error_messages_for_post
    error_messages_for :post, 
      :header_message => ttt(:validation_error_header, :model => @type.to_s),  
      :message => ttt(:validation_error_message)
  end

  def edit_videos_for_assoc(resource)
    list_id = "videos_list"
    if resource and resource.respond_to?(:videos)
      content_tag(:div, :id => list_id, :class => "media-list") do
        content_tag(:ul, :id => "#{list_id}_ul") do
          resource.videos.map do |video|
            # Each video
            width = 186
            height = 124
            embed = video.embedable?
            content_tag(:li, :id => video.dom_id(list_id)) do
              link_to(image_tag("admin/remove.png"), admin_video_path(video, :format => :js), :remote => true, :method => :delete, :confirm => "Are you absolutely sure?") +
              content_tag(:div, (embed ? video.embed(:width => width, :height => height) : video.url), :id => video.dom_id) +
              (embed ? "" : javascript_tag(%Q{
                $('##{video.dom_id}').flash({ src: '#{video.embed_url}', width: #{width}, height: #{height} });
              })) +
              text_area_tag("#{resource.class.to_s.downcase}[videos_attributes][][caption]", video.caption) +
              hidden_field_tag("#{resource.class.to_s.downcase}[videos_attributes][][id]", video.id)
            end
          end
        end +
        sortable_element("#{list_id}_ul", :axis => "x")
      end
    end
  end

  include Terryblr::Extendable
end