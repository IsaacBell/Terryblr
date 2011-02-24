module Terryblr::PostsHelper

  def like_label(post)
    count = post.likes.count
    str = count.zero? ? "Like this?" : "#{pluralize(count, 'people')} like this"
    content_tag :div, link_to(str, post_likes_path(post), :remote => true), :id => post.dom_id('like_label')
  end

  def post_item(post)
    content_tag(:div, :class => "post-title") do
      link_to_unless_current(post.title? ? post.title : post.published_at.to_s(:date_ordinal), post_path(post, post.slug))
    end + 
    case post.post_type.to_sym
    when :photos
      photos_post_body(post)
    when :video
      video_body(post)
    else
      post_body(post)
    end +
    
    # Tags
    post_action_links(post)

  end

  def post_body(post)
    parts = post.body.to_s.split('<!--more-->')
    if parts.size > 1 && controller.action_name!='show'
      parts.first.to_s + "... " + link_to("Continue reading #{post.title}.", post_path(post, post.slug))
    else
      post.body.to_s
    end
  end

  def video_body(post)
    video = post.videos.first
    return "No videos found" unless video

    # Details and list sizes are different
    width = 630
    height = ((width.to_f/video.width) * video.height).to_i

    str =  content_tag(:div, "", :id => video.dom_id, :class => "post-video")
    str += if video.embedable?
      video.embed(:width => width, :height => height)
    elsif video.vimeo_id? and !video.embed_url.blank?
      javascript_tag(%Q{
        $('##{video.dom_id}').flash({
            src: '#{video.embed_url}', width: #{width}, height: #{height},
            flashvars: {}
        });
      })
    end
    str += post_body(post)
    str
  end
  
  def post_action_links(post)
    content_tag(:div, :class => "post-links clear") do 
      content_tag(:ul) do 
        lnks = [
          link_to("+ Share", post_url(post, post.slug), :class => "share", :title => "#{Settings.app_name} - #{post.title}"),
          post.tag_list.map{|t| link_to(t.titleize, tagged_posts_path(t), :class => "tag") }
        ].flatten
        lnks.map{|lnk| content_tag(:li, lnk) }.join.html_safe
      end
    end
  end

end
