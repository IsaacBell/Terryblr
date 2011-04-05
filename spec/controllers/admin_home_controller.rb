require 'spec_helper'

describe Terryblr::AdminHomeController do
  
  describe "POST /admin/switch_site" do
    
    before do
      @user = Factory(:user_admin)
      @site_www = Factory(:site, :name => "www")
      @site_blog = Factory(:site, :name => "blog")
      @post_www = Factory(:post, :site => @site_www)
      @post_blog = Factory(:post, :site => @site_blog)
    end
    
    it "switches current site" do

      sign_in @user

      # Go to admin archives with default site
      get :index
      response.should be_success
      assigns(:current_site).should eql(@site_www)
      
      # Switch to another site
      post :switch_site, :site => @site_blog.name
      response.should be_redirect
      
      # Current site has changed and posts are different
      get :index
      response.should be_success
      assigns(:current_site).should eql(@site_blog)
      
    end
  end
  
end