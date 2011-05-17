require 'spec_helper'

describe Terryblr::AdminHomeController do
  
  describe "POST /admin/switch_site" do
    
    before do
      @user = Factory(:user_admin)
      @site_www = Terryblr::Site.default
      @site_blog = Factory(:site, :lang => :fr)
      @post_www = Factory(:post, :site => @site_www)
      @post_blog = Factory(:post, :site => @site_blog)
    end
    
    it "switches current site" do

      sign_in @user

      # Go to admin archives with default site
      @site_www.lang.should eql(:en)
      get :index
      response.should be_success
      assigns(:current_site).should eql(@site_www)
      assigns(:current_lang).should eql(:en)
      
      # Switch to another site
      post :switch_site, :site => @site_blog.name
      response.should be_redirect
      
      # Current site has changed and posts are different
      @site_blog.lang.should eql(:fr)
      get :index
      response.should be_success
      
      assigns(:current_site).should eql(@site_blog)
      assigns(:current_lang).should eql(:fr)
      
    end
  end
  
end