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
      
      # Switch to another site
      
      # Current site has changed and posts are different
      
    end
  end
end