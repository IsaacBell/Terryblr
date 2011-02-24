# Methods added to this helper will be available to all templates in the application.
module Terryblr::ApplicationHelper

  def facebook_meta_tags
    return unless page_object

    title = Settings.app_name + " - #{page_title}"

    str  = tag(:meta, :name => "title", :content => title) + "\n"
    str += tag(:meta, :name => "description", :content => page_description)
    
    return str unless object.respond_to?(:post_type)
    
    str += case page_object.post_type.to_s
    when "video"
      if page_object.videos.empty?
        ""
      else
        v = page_object.videos.first
        tag(:link, :rel => "video_src", :href => v.embed_url, :title => title) + "\n" +
        tag(:meta, :rel => "video_height", :content => v.height) + "\n" +
        tag(:meta, :rel => "video_width", :content => v.width) + "\n" +
        tag(:meta, :rel => "video_type", :content => "application/x-shockwave-flash") + "\n" +
        tag(:link, :rel => "image_src", :href => v.thumb_url, :title => title)
      end
    else
      if page_object.photos.empty?
        ""
      else
        p = page_object.photos.first
        tag(:link, :rel => "image_src", :href => p.image.url(:thumb), :title => title) + "\n" +
        tag(:meta, :name => "medium", :content => "image")
      end
    end
    str
  end
  
  def page_title
    return "" if page_object.nil? and @page_title.nil?

    @page_title ? @page_title : page_object.title
  end

  def page_description
    return "" if page_object.nil?
    truncate_words(strip_tags(page_object.body.to_s), :length => 20, :omission => "...")
  end

  def page_object
    @page_object ||= @post || @page || @object || nil
    @page_object ||= @posts.first if @posts
    @page_object
  end
  
  def detail_page?
    case controller.controller_name.to_sym
    when :contributors
      false
    else
      (controller.action_name=='show')
    end
  end

  def photos_post_body(object)
    obj_type = object.class.to_s.downcase.split('::').last

    # Rejection cases
    return unless %w(post product page).include?(obj_type.to_s)
    return if object.photos.empty?
    
    detail_path = send("#{obj_type}_path",object.to_param, object.slug)
    image_size = detail_page? ? :medium : :list
    thumb_panes = detail_page? ? 6 : 4
    thumb_photos = object.photos[(detail_page? ? 0 : 1)..(detail_page? ? object.photos.count : thumb_panes+1)]
    is_gallery = (object.respond_to?(:display_type) and object.display_type? and object.display_type.gallery?)

    content_tag(:div, :class => "photos-slideshow") do
      content_tag(:div, :class => (detail_page? && is_gallery) ? "slideshow" : "stacked-photos") do
        photos = detail_page? ? object.photos : [object.photos.first]
        photos.map do |f|
          display = (f==object.photos.first || !is_gallery) ? "block" : "none"
          dom_id = f.dom_id
          # Make link
          content_tag(:div, :id => dom_id, :class => "slide", :style => "display:#{display}") do
            s = f.size(image_size) rescue {}
            link_to(image_tag(f.image.url(image_size), :size => [s[:width], s[:height]].join('x')), send("#{obj_type}_path",object.to_param, object.slug, :anchor => dom_id), :name => dom_id) +
            content_tag(:p, (f.caption? ? f.caption : " "), :class => "photo-caption")
          end
        end.join.html_safe
      end +
      
      # Only show thumbs on details page
      if thumb_photos.size > 1 && (!detail_page? || is_gallery)
        content_tag(:div, :class => "slideshow-controls") do
          content_tag(:ul, :class => "slideshow-controls-container #{'carousel' if detail_page? && thumb_photos.size > thumb_panes}") do
            thumb_photos.map do |p|
              content_tag(:li) do 
                link_to(image_tag(p.image.url(:thumb), :size => "95x95"), send("#{obj_type}_path", object, object.slug, :anchor => p.dom_id), :class => (p==thumb_photos.last ? "last" : ""))
              end
            end.join.html_safe
          end
        end
      end.to_s

    end +
    content_tag(:div, "", :class => "clear") +
    post_body(object).html_safe
  end

  #
  # Common
  #
  def flash_messages
    return unless messages = flash.keys.select{|k| [:notice, :message, :warning, :error].include?(k)}
    content_tag :div, :id => "flash" do
      messages.map do |type|
        content_tag :div, :id => "flash-#{type.to_s}", :class => "flash #{type.to_s}" do
          content_tag :span, message_for_item(flash[type], flash["#{type}_item".to_sym])
        end
      end.join("\n")
    end
  end

  def message_for_item(message, item = nil)
    if item.is_a?(Array)
      message % link_to(*item)
    else
      message
    end
  end

  def session_key
    @session_key ||= Rails.application.config.session_options[:key]
  end

  def link_current_block
    @link_current_block ||= Proc.new { |name| content_tag(:span, name); }
  end

  def body_classes
    con = params[:controller].split('/').last.strip
    act = params[:action].strip
    id  = @object ? @object.to_param : nil
    "#{con} #{con}-#{act} #{id} #{@body_classes.to_s}"
  end

  def truncate_words(txt, ops = {})
    ops.reverse_merge({
      :length => 100, 
      :omission   => "..."
    })
    words = txt.to_s.split()
    words[0..(ops[:length]-1)].join(' ').to_s + (words.length > ops[:length] ? ops[:omission] : '').to_s
  end

  #
  # Forms and Lists
  #
  def col_to_field(col)
    case col.type
    when :text
      :text_area
    when :boolean
      :check_box
    when :date
      :date_select
    when :datetime, :time
      :datetime_select
    else
      :text_field
    end
  end

  def col_to_class_name(col)
    case col.type
    when :text
      :textarea
    when :boolean
      :checkbox
    when :date, :datetime, :time
      :select
    else
      :text
    end
  end

  def sort_col(col)
    col_sym = col.class.to_s.downcase.to_sym rescue nil
    case col_sym
    when :datetime, :time
      "date-iso"
    else
      "text"
    end
  end
  
  def action_link(action, record, record_name, final_options = {})
    url = case action.to_sym
    when :show, :destroy, :update
      "#{record_name}_path"
    when :edit
      "edit_#{record_name}_path"
    when :new
      "new_#{record_name}_path"
    else
      "#{action}_#{record_name}_path"
    end

    options = case action.to_sym
    when :destroy
      {:confirm => 'Are you sure?', :method => :delete}
    when :moderate
      {:confirm => 'Are you sure?', :method => :put }
    end
    options ||= {}

    link_to action.capitalize, send(url, record), {:class => action}.merge(options).merge(final_options)
  end

end
