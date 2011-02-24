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

        photos = []
        image_urls[0..9].each do |url| # limit the images to be imported
        # image_urls.each do |url|
          photos << Photo.create!(:url => url)
        end

        full_title = post.css('title').text #place and date

        options = {
          :slug => fetch_slug(post),
          :body => fetch_date(full_title),
          :title => fetch_location(full_title),
          :tag_list => parse_tags(post),
          :photos => photos,
          :post_type => "photos",
          :state => "published",
          :published_at => post.css('published').text,
          :display_type => "photos"
        }

        # Create Post with photo
        p = Post.create!(options)
        
        puts "Created post '#{p.title}'"
         
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
        video = Video.create!(:url => post["video-source"].to_s)

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
        Post.create!(options)
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
        Post.create!(options)
      end

      def import_photo(post, state = 'published')
        printf "*  Importing photo : #{post.inspect}\n"

        # Create Photos first
        if post.has_key?("photoset")
          # multiple photos
          photos = Photo.create!(post['photoset'].first["photo"].map { |photo| { :url => photo["photo-url"].first["content"] } })
        else
          photos = [ Photo.create!(:url => post['photo-url'].first["content"]) ]
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
        Post.create!(options)
      end
    end

  end
  
end