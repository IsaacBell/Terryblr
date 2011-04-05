require 'spec_helper'

describe Terryblr::Site do
  describe "validation" do
    before do
      @site = Factory(:site)
    end

    it "should be valid and create a site" do
      site = Terryblr::Site.new(:name => "www")
      site.valid?.should eql(true)
      site.save.should eql(true)
    end

    it "should not be valid with non-unique name" do
      site = Terryblr::Site.new(:name => @site.name)
      site.save.should eql(false)
      site.valid?.should eql(false)
      site.errors.on(:name).nil?.should eql(false)
    end

    it "should not be valid without a name" do
      site = Terryblr::Site.new()
      site.save.should eql(false)
      site.valid?.should eql(false)
      site.errors.on(:name).nil?.should eql(false)
    end
  end
  
  describe "site scoping" do
    before do
      @site_www = Factory(:site, :name => "www")
      @post_www = Factory(:post, :site => @site_www)
      @page_www = Factory(:page, :site => @site_www)
      @feature_www = Factory(:feature, :site => @site_www)

      @site_blog = Factory(:site, :name => "blog")
      @post_blog = Factory(:post, :site => @site_blog)
      @page_blog = Factory(:page, :site => @site_blog)
      @feature_blog = Factory(:feature, :site => @site_blog)
    end

    it "should include different posts for different sites" do

      @site_www.reload
      @site_www.posts.include?(@post_www).should eql(false)
      @site_www.pages.include?(@page_www).should eql(false)
      @site_www.features.include?(@feature_www).should eql(false)

      @site_blog.reload
      @site_blog.posts.include?(@post_blog).should eql(false)
      @site_blog.pages.include?(@page_blog).should eql(false)
      @site_blog.features.include?(@feature_blog).should eql(false)

    end
  end

end