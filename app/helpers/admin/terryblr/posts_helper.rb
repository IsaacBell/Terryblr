module Admin::Terryblr::PostsHelper

  def error_messages_for_post
    error_messages_for :post, 
      :header_message => "Uh oh. We found some problems with your #{@type.to_s}...", 
      :message => "Please review the following fields:"
  end

  def edit_videos_for_assoc(object)
    list_id = "videos_list"
    if object and object.respond_to?(:videos)
      content_tag(:div, :id => list_id, :class => "media-list") do
        content_tag(:ul, :id => "#{list_id}_ul") do
          object.videos.map do |video|
            # Each video
            width = 186
            height = 124
            embed = video.embedable?
            content_tag(:li, :id => video.dom_id(list_id)) do
              link_to_remote(image_tag("admin/remove.png"), :url => admin_video_path(video, :format => :js), :method => :delete, :confirm => "Are you absolutely sure?") +
              content_tag(:div, (embed ? video.embed(:width => width, :height => height) : video.url), :id => video.dom_id) +
              (embed ? "" : javascript_tag(%Q{
                $('##{video.dom_id}').flash({ src: '#{video.embed_url}', width: #{width}, height: #{height} });
              })) +
              text_area_tag("#{object.class.to_s.downcase}[videos_attributes][][caption]", video.caption) +
              hidden_field_tag("#{object.class.to_s.downcase}[videos_attributes][][id]", video.id)
            end
          end
        end +
        sortable_element("#{list_id}_ul", :url => reorder_admin_videos_path(:format => :js), :constraint => "horizontal")
      end
    end
  end

end
