require 'open-uri'
require 'nokogiri'

desc "This task is called by the Heroku cron add-on"
task :cron => :environment do

  djs = []
  dj_priority = -1
  time = Time.now.in_time_zone

  # On heroku the daily cron job will run this
  djs << Terryblr::Tweet.send_later(:fetch_recent)

  # Each minute

  # Each Hour at a certain minute
  case time.min
  when 0
  end

  # Top of each hour
  case time.hour
  when 0
  when 7
    # At the top of the hour

  when 8
    # At the top of the hour

  end if time.min.zero?

  # Top of each wday
  case time.wday
  when 0

  end

  # Set priority on all the delayed-jobs create here
  Delayed::Job.update_all({:priority => dj_priority}, ["id in (?)", djs.map(&:id)])

end

namespace :terryblr do
  desc "Greeting rake task from Terryblr"
  task :greet do
    puts "Greeting from Terryblr"
  end
  
  namespace :import do
    
    namespace :blogger do
      desc "Import published posts from blogger. Provide a FILE=path_to_exported_xml_file as a source."
      task :published => :environment do 
        # Read in full file
        blog = Nokogiri::XML(open(ENV['FILE']))
        # Select entries that are blog posts
        entries = blog.css('entry').select{|e| !e.css('content[type=html]').blank? }
        # Import each post
        entries.each { |e| import_post(e) }
      end

      private

      def import_post(post)
        #rip out image urls and create associated images; assumes all blog posts are just images

        require 'htmlentities'
        @decoder ||= HTMLEntities.new

        content_html = @decoder.decode(post.css('content').text)
        content = Nokogiri::HTML(content_html)
        image_urls = content.css("img").map{|i|i.attributes['src'].to_s}

        title = post.css('title').text #place and date
        url = post.at_css("link[rel='alternate'][type='text/html']")['href'] rescue nil


        # Create Post with photo unless already exists.
        if Terryblr::Post.find_by_import_url(url).nil?
          photos = []
          image_urls[0..(Rails.env.development? ? 9 : image_urls.size)].each do |url| # limit the images to be imported
          # image_urls.each do |url|
            photo = Terryblr::Photo.create(:url => url)
            if photo.valid?
              photos << photo
            else
              puts "Skipping image '#{url}' - #{photo.errors.full_messages.to_sentence}"
            end
          end
        
          options = {
            :slug => fetch_slug(post),
            :body => fetch_date(title),
            :title => fetch_location(title),
            :tag_list => parse_tags(post),
            :photos => photos,
            :post_type => "photos",
            :state => "published",
            :published_at => post.css('published').text,
            :display_type => "photos",
            :import_url => url
          }
          p = Terryblr::Post.create!(options)
          puts "Created post '#{p.title}'"

        else
          puts "Skipping '#{title}' - already imported!"

        end
      end

      #these is used to split appropriately, for example if a post is titled "London, September 21st, 2009" vs "London, England, September 21st, 2009"
      def fetch_date(title)
        #if the split section includes a number, assume it is part of the date
        title.to_s.split(",").select{ |section| section =~ /\d/ }.map(&:strip).join(", ")
      end

      def fetch_location(title)
        title.to_s.split(",").select{ |section| section !~ /\d/ }.map(&:strip).join(", ")
      end

      def parse_tags(post)
        post.css("category[scheme$='atom/ns#']").map{|c|c["term"]}
      end

      def fetch_slug(post)
        if link = post.at_css("link[rel='alternate'][href^='http://yvanrodic.blogspot.com/']")
          link["href"].split("/").last.split(".").first.to_param
        end
      end

    end

    namespace :tumblr do
      desc "Import published posts from tumblr."
      task :published => :environment do
        printf "** Importing published posts\n"

        per_page = 50

        total_posts = get(:num => 1).match(/total="(\d+)"/)[1].to_i
        total_pages = (total_posts / per_page.to_f).ceil

        printf "** #{total_posts} items to be imported!\n"

        # FOR DEBUG
        #total_pages, per_page = 1, 1

        (1..total_pages).each do |current_page|
          printf "\n** Getting page #{current_page} of #{total_pages} ( #{per_page} per page )\n"

          body = get({ :start => (current_page - 1) * per_page, :num => per_page })
          posts = XmlSimple.xml_in(body)["posts"].first["post"]

          import_posts(posts)
        end
      end

      desc "Import drafted posts from tumblr."
      task :drafted => :environment do
        printf "** Importing drafted posts\n"

        fetch_next_page = true
        current_page = 1

        per_page = 20 # 20 is the default value per_page from Tumblr API
        # the :num attribute when POST'ing on Tumblr API seems not to be taken into account
        # A bug >_<

        while fetch_next_page
          printf "\n** Getting page #{current_page}\n"

          body = get({ :start => (current_page - 1) * per_page, :num => per_page, :state => "draft" }, true)
          posts = XmlSimple.xml_in(body)["posts"].first["post"]

          if posts.nil? or posts.empty?
            fetch_next_page = false
          else
            printf "** #{posts.count} posts found\n"

            import_posts(posts, "drafted")
            fetch_next_page = (posts.count == per_page)
            current_page += 1
          end
        end
      end

      private

      def import_posts(posts, state="published")
        posts.each do |post|
          begin
            case post['type']
            when "photo" then import_photo(post, state)
            when "regular" then import_regular(post, state)
            when "video" then import_video(post, state)
            else
              printf "** Skipping #{post["type"]} post, no handler\n"
            end
          rescue => exc
            puts "Error: #{exc}"
            puts exc.backtrace
          end
        end
      end

      def get(params = {}, authenticate = false)
        blog_uri = "http://www.terrysdiary.com/api/read"
  #      blog_uri = "http://#{Settings.tumblr.blog}.tumblr.com/api/read"

        if authenticate
          params[:email] = "diary@terryrichardson.com"
          params[:password] = "bowery1"

          #params[:email] = Settings.tumblr.email
          #params[:password] = Settings.tumblr.pass

          Mechanize.new.post(blog_uri, params).body
        else
          Mechanize.new.get("#{blog_uri}?" + params.to_query).body
        end
      end

      def import_video(post, state = "published")
        printf "*  Importing video : #{post.inspect}\n"

        # Create video first
        video = Terryblr::Video.create!(:url => post["video-source"].to_s)

        title =  post["slug"].gsub(/-/, " ").humanize rescue "Draft #{Time.now.to_i}"

        options = {
          :tumblr_id => post['id'],
          :slug => post['slug'],
          :title => title,
          :tag_list => post['tag'].to_a.join(', '),
          :post_type => "video",
          :state => state,
          :videos => [video],
          :published_at => post['date']
        }

        # Create Post with photo
        Terryblr::Post.create!(options)
      end

      def import_regular(post, state = "published")
        printf "*  Importing regular post : #{post.inspect}\n"

        options = {
          :tumblr_id => post['id'],
          :slug => post['slug'],
          :title => post["regular-title"].to_s,
          :body => post['regular-body'].to_s,
          :tag_list => post['tag'].to_a.join(', '), 
          :post_type => "post",
          :state => state,
          :published_at => post['date']
        }

        # Create Post with photo
        Terryblr::Post.create!(options)
      end

      def import_photo(post, state = 'published')
        printf "*  Importing photo : #{post.inspect}\n"

        # Create Photos first
        if post.has_key?("photoset")
          # multiple photos
          photos = Terryblr::Photo.create!(post['photoset'].first["photo"].map { |photo| { :url => photo["photo-url"].first["content"] } })
        else
          photos = [ Terryblr::Photo.create!(:url => post['photo-url'].first["content"]) ]
        end

        title =  post["slug"].gsub(/-/, " ").humanize rescue ""

        title = "Draft #{Time.now.to_i}" if title.blank?

        options = {
          :tumblr_id => post['id'],
          :slug => post['slug'],
          :title => title,
          :body => post['photo-caption'].to_s,
          :tag_list => post['tag'].to_a.join(', '), 
          :photos => photos,
          :post_type => "photos",
          :state => state,
          :published_at => post['date']
        }

        # Create Post with photo
        Terryblr::Post.create!(options)
      end
    end

    namespace :wordpress do
      task :published => :environment do
        i=11
        continue=true

        while continue == true
          i+=1
          begin 
            puts i
            feed_url ="#{ENV['BASEURI']}/feed/?paged=#{i}"
            puts feed_url
            blog_page = Nokogiri::XML(open(feed_url))
            blog_page.css("item").each do |e|
              if has_video(e)
                import_video(e)
              elsif has_photos(e)
                import_photo(e)
              else
                import_regular(e)
              end
            end
          rescue => detail
            print detail.backtrace.join("\n")
            continue=false
          end
        end
      end

      private

      def import_regular(post, state = "published")
        photos = []
        structured_post_content = Nokogiri::HTML.parse(post.xpath('.//content:encoded').text)

        #Download/Reinsert Images
        if (structured_post_content.css('img').count > 0)
          structured_post_content.css('img').each do |i|
            #create photo from a href link source
            original_image_url = i.parent.attribute("href") ? i.parent.attribute("href").value : i.attribute("src").value
            photo = Terryblr::Photo.create!(:url => original_image_url)
            #fetch new image urls (thumb and original)
            #modify body to reflect new images
            new_image_url = photo.image.url(:medium)
            i.attribute("src").value = new_image_url

            if i.parent.attribute("href")
              new_link_url = photo.image.url
              i.parent.attribute("href").value = new_link_url
            end
            photos << photo
          end
        end

        options = {
          :slug => post.at_css("link").text.split("/").last,
          :body => structured_post_content.to_s,
          :title => post.at_css("title").text,
          :tag_list => post.css("category").map(&:text).join(", "), 
          :state => state,
          :post_type => "post",
          :photos => photos,
          :published_at => post.at_css("pubDate").text
        }

        # Create Post with photo
        Terryblr::Post.create!(options)

      end

      def import_video(post, state = "published")
        photos = []

        structured_post_content = Nokogiri::HTML.parse(post.xpath('.//content:encoded').text)
        vid_url = video_url(structured_post_content)
        #Delete native embed
        structured_post_content.at_css("iframe").remove
        #Create video for Terryblr embed
        video = Terryblr::Video.create!(:url => vid_url)

        #Download/Reinsert Images
        if (structured_post_content.css('img').count > 0)
          structured_post_content.css('img').each do |i|
            #create photo from a href link source
            original_image_url = i.parent.attribute("href").value
            photo = Terryblr::Photo.create!(:url => original_image_url)

            #fetch new image urls (thumb and original)
            new_link_url = photo.image.url
            new_image_url = photo.image.url(:medium)

            #modify body to reflect new links
            i.parent.attribute("href").value = new_link_url
            i.attribute("src").value = new_image_url

            photos << photo
          end
        end

        options = {
          :slug => post.at_css("link").text.split("/").last,
          :body => structured_post_content.to_s,
          :title => post.at_css("title").text,
          :tag_list => post.css("category").map(&:text).join(", "), 
          :state => state,
          :post_type => "video",
          :photos => photos,
          :videos => [video],
          :published_at => post.at_css("pubDate").text
        }

        # Create Post with photo
        Terryblr::Post.create!(options)
      end



      def has_video(post)
        #does it have an iframe titled Youtube or Vimeo in its content?
        iframe_node = Nokogiri::HTML.parse(post.xpath('.//content:encoded').text).at_css("iframe")
        if iframe_node
          if iframe_node.attribute("title").value =~ /YouTube/
            video_url = iframe_node.attribute("src").value
            return true
          #elsif vimeo..
            #check if vimeo objects contain a "title" attribute structured similarly
          end
        else
          return false
        end
      end

      def has_photos(post)
        return false #for now
      end

      def video_url(content)
        iframe_node = content.at_css("iframe")
        if iframe_node.attribute("title").value =~ /YouTube/
          return video_url = iframe_node.attribute("src").value.split("/").last.insert(0, "http://www.youtube.com/watch?v=")
        #elsif vimeo..
          #check if vimeo objects contain a "title" attribute structured similarly
        end
      end

    end

  end

end