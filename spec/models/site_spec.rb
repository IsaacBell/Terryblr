require 'spec_helper'

describe Terryblr::Site do
  describe "validation" do
    before do
      @site = Factory(:site)
    end

    it "should be valid and create a site" do
      site = Terryblr::Site.new(:name => "www")
      site.valid?.should be(true)
      site.save.should be(true)
    end

    it "should not be valid with non-unique name" do
      site = Terryblr::Site.new(:name => @site.name)
      site.save.should be(false)
      site.valid?.should be(false)
      site.errors[:name].nil?.should be(false)
    end

    it "should not be valid without a name" do
      site = Terryblr::Site.new()
      site.save.should be(false)
      site.valid?.should be(false)
      site.errors[:name].nil?.should be(false)
    end
  end
  
  describe "site scoping" do
    before do
      @site_www = Terryblr::Site.default
      @post_www = Factory(:post, :site => @site_www)
      @page_www = Factory(:page, :site => @site_www)
      @feature_www = Factory(:feature, :site => @site_www)

      @site_blog = Factory(:site, :name => "blog")
      @post_blog = Factory(:post, :site => @site_blog)
      @page_blog = Factory(:page, :site => @site_blog)
      @feature_blog = Factory(:feature, :site => @site_blog)
    end

    it "should include different posts for different sites" do

      # Not empty?
      [@site_www.posts, @site_www.pages, @site_www.features, @site_blog.posts, @site_blog.pages, @site_blog.features].each do |coll|
        coll.empty?.should be(false)
      end

      # Positives
      @site_blog.posts.include?(@post_blog).should be(true)
      @site_blog.pages.include?(@page_blog).should be(true)
      @site_blog.features.include?(@feature_blog).should be(true)
      
      @site_www.posts.include?(@post_www).should be(true)
      @site_www.pages.include?(@page_www).should be(true)
      @site_www.features.include?(@feature_www).should be(true)
      
      # Negatives
      @site_blog.posts.include?(@post_www).should be(false)
      @site_blog.pages.include?(@page_www).should be(false)
      @site_blog.features.include?(@feature_www).should be(false)
      
      @site_www.posts.include?(@post_blog).should be(false)
      @site_www.pages.include?(@page_blog).should be(false)
      @site_www.features.include?(@feature_blog).should be(false)

    end
  end

end