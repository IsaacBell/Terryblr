require 'spec_helper'

describe Terryblr::AdminHomeController do
  describe "POST /admin/switch_site" do
    
    before do
      @site_www = Factory(:site, :name => "www")
      @site_blog = Factory(:site, :name => "blog")
      @post_www = Factory(:post, :site => @site_www)
      @post_blog = Factory(:post, :site => @site_blog)
    end
    
    it "switches current site" do

      # Go to admin archives with default site
      get admin_posts_path
      response.should be_success
      
      # Switch to another site
      get admin_switch_site_path(:site => @site_blog.name)
      response.should be_success
      
      # Current site has changed and posts are different
      get admin_posts_path
      response.should be_success
      
    end
  end
end