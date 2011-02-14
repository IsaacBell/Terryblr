# Methods added to this helper will be available to all templates in the application.
module Terryblr::ApplicationHelper

  def share_item(object)
    content_tag(:div, :class => "share-post") do
      content_tag(:ul) do
        # Twitter
        # <iframe width="90" scrolling="no" height="20" frameborder="0" src="http://api.tweetmeme.com/widget.js?url=http://techcrunch.com/2010/04/01/social-network-hi5-raises-23-million-in-funding/&amp;style=compact&amp;source=TechCrunch&amp;service=bit.ly"></iframe>
        content_tag(:li, :class => "twitter") do
          content_tag(:iframe, "", :width => "90", :scrolling => "no", :height => "20", :frameborder => "0", :src => "http://api.tweetmeme.com/widget.js?url=#{request.url}&amp;style=compact&amp;source=#{Settings.app_name}&amp;service=bit.ly")
        end

        # Facebook
        content_tag(:li, :class => "facebook") do
          # <a style="text-decoration: none;" href="http://www.facebook.com/sharer.php?u=http%3A%2F%2Ftechcrunch.com%2F2010%2F04%2F01%2Fsocial-network-hi5-raises-23-million-in-funding%2F&amp;t=Social%20Network%20hi5%20Raises%20%243%20Million%20In%20Debt%20From%20Mohr%20Davidow&amp;src=sp" name="fb_share" id="fb_share" share_url="http://techcrunch.com/2010/04/01/social-network-hi5-raises-23-million-in-funding/" class="snap_nopreview"><span class="fb_share_size_Small "><span class="FBConnectButton FBConnectButton_Small" style="cursor: pointer;"><span class="FBConnectButton_Text">Share</span></span><span class="fb_share_count_nub_right "></span><span class="fb_share_count  fb_share_count_right"><span class="fb_share_count_inner">7</span></span></span></a>
          # <script src="http://www.facebook.com/connect.php/js/FB.SharePro/" type="text/javascript"></script>
          link_to("")
        end
        
        # Tumblr
      
        # Google Buzz
      end
    end
  end
  
  def facebook_meta_tags

    return "<!-- No info for FB headers -->" unless page_object

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
  
  

  def photos_post_body(object)
    obj_type = object.class.to_s.downcase.to_sym

    # Rejection cases
    return unless [:post, :product, :page].include?(obj_type)
    return if object.photos.empty?

    detail_path = send("#{obj_type}_path",object.to_param, object.slug)
    detail_page = current_page?(detail_path)
    flash_dom = object.dom_id("flash_slideshow")
    
    content_tag(:div, :class => "photos-slideshow") do
      
      content_tag(:div, :class => detail_page ? "slideshow" : "") do
        photos = detail_page ? object.photos : [object.photos.first]
        photos.map do |f|
          display = (f==object.photos.first) ? "block" : "none"
          link_to image_tag(f.image.url(:medium), :size => f.size(:medium)), send("#{obj_type}_path",f.photoable.to_param,object.slug, :anchor => f.dom_id), :style => "display:#{display}"
        end.join
      end +
      
      # Only show thumbs on details page
      if object.photos.size > 1
        content_tag(:div, :class => "slideshow_controls") do
          object.photos.map do |p|
            link_to image_tag(p.image.url(:thumb)), detail_path
          end.join
        end
        
        # # Full screen player
        # link_to_function("Play in Full-screen", "$('##{flash_dom}').flash('enterFullScreenDisplayState');") +
        # content_tag(:div, "", :id => flash_dom) +
        # javascript_tag(%Q{
        #   $('##{flash_dom}').flash({
        #       src: '/flash/slideshowpro.swf', width: 0, height: 0,
        #       flashvars: {
        #         paramXMLPath: "#{send("gallery_params_#{obj_type}_path",object, :format => 'xml')}",
        #         xmlfiletype: "Default"
        #       }
        #   }).hide()
        # }) + 
        
        object.body
        
      end.to_s
    end
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
    @session_key ||= ActionController::Base.session_options[:key]
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
