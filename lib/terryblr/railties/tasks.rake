module ActiveRecord
  class Migrator
    class << self
      def migrations(paths)
        paths = Array.wrap(paths)

        files = Dir[*paths.map { |p| "#{p}/[0-9]*_*.rb" }]

        seen = Hash.new false

        migrations = files.map do |file|
          version, name = file.scan(/([0-9]+)_([_a-z0-9]*).rb/).first

          raise IllegalMigrationNameError.new(file) unless version
          version = version.to_i
          name = name.camelize

          raise DuplicateMigrationVersionError.new(version) if seen[version]
          raise DuplicateMigrationNameError.new(name) if seen[name]

          seen[version] = seen[name] = true
        
          migration = MigrationProxy.new
          migration.name = name
          migration.filename = file
          migration.version = version
          migration
        end

        migrations.sort_by(&:version)
      end
    end
  end
  
  class Migration
    class << self
      def copy(destination, sources, options = {})
        copied = []

        FileUtils.mkdir_p(destination) unless File.exists?(destination)

        destination_migrations = ActiveRecord::Migrator.migrations(destination)
        last = destination_migrations.last
        sources.each do |name, path|
          source_migrations = ActiveRecord::Migrator.migrations(path)

          source_migrations.each do |migration|
             
             
            source = File.read(migration.filename)
            source = "# This migration comes from #{name} (originally #{migration.version})\n#{source}"
            
            if duplicate = destination_migrations.detect { |m| m.name == migration.name }
              options[:on_skip].call(name, migration) if File.read(duplicate.filename) != source && options[:on_skip]
              next
            end
            
            # migration.version = next_migration_number(last ? last.version + 1 : 0).to_i
            new_path = File.join(destination, "#{migration.version}_#{migration.name.underscore}.rb")
            old_path, migration.filename = migration.filename, new_path
            last = migration
            
            FileUtils.cp(old_path, migration.filename)
            copied << migration
            options[:on_copy].call(name, migration, old_path) if options[:on_copy]
            destination_migrations << migration
          end
        end

        copied
      end
    end
  end
end

class Hash
  def to_query
    result = []
    each do |k, v|
      result << "#{k}=#{v}"
    end
    result.join("&")
  end
end

namespace :terryblr do
  namespace :install do
    desc "Copy migrations from Terryblr to application"
    task :migrations => :"db:load_config" do
      
      # Adapted from rails edge activerecord/lib/active_record/railties/databases.rake
      on_skip = Proc.new do |name, migration|
        puts "NOTE: Migration #{migration.name} from #{name} has been skipped. Migration with the same name already exists."
      end

      on_copy = Proc.new do |name, migration, old_path|
        puts "Copied migration #{migration.name} from #{name}"
      end

      ActiveRecord::Migration.copy( 'db/migrate', { 'terryblr' => Terryblr::Engine.new.paths['db/migrate'].first }, :on_skip => on_skip, :on_copy => on_copy)
    end
  end
  
  namespace :import do
    
    namespace :blogger do
      task :published => :environment do 
        # Read in full file
        blog = Nokogiri::XML(open(ENV['PATH']))
        # Select entries that are blog posts
        entries = blog.css('entry').select{|e| e.is_post? }
        # Import each post
        entries.each { |e| import_post(e) }
      end


      private

      def import_post(post)
        #rip out image urls and create associated images; assumes all blog posts are just images

        content_html = decoder.decode(post.css('content').text)
        content = Nokogiri::XML(content_html)
        image_urls = content.css("img").map{|i|i.attributes['src'].to_s}

        photos = []
        image_urls.each do |url|
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
          :published_at => post.css('published').text
        }
        puts options.inspect

        # Create Post with photo
        Post.create!(options)  
      end

      #these is used to split appropriately, for example if a post is titled "London, September 21st, 2009" vs "London, England, September 21st, 2009"
      def fetch_date(title)
        #if the split section includes a number, assume it is part of the date
        title_array = title.split(",")
        return title_array.select{ |section| section =~ /\d/ }.join(",").strip
      end

      def fetch_location(title)
        title_array = title.split(",")
        return title_array.select{ |section| (section =~ /\d/).nil? }.join(",").strip
      end

      def parse_tags(post)
        category_elts = post.css('category') 
        tags_array=Array.new
        category_elts.each do |c|
         (tags_array << c["term"]) if c.is_tag?
        end
        tags_array.inspect
        tags_array.empty? ? (return nil) : (return tags_array.join(', '))
      end

      def fetch_slug(post)
        post.css("link[rel='alternate']").last().attributes["href"].to_s.split("/").last().gsub(".html", "")
      end

      def decoder 
        require 'htmlentities'
        @decoder ||= HTMLEntities.new
      end

      def is_post?
        self.at_css('content')['type'] == "html"
      end

      def is_tag?
        self['scheme'] =~ /atom\/ns#/
      end
    end

    namespace :tumblr do
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

