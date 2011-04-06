require 'spec_helper'

describe Terryblr::PostsController do

  describe "GET /posts" do
  end

  describe "GET /posts/show" do
  end

  describe "GET /posts/tagged" do
  end

  describe "GET /posts/archive" do
  end
  
  describe "GET /posts/next,previous" do
    
    before do
      @posts = []
      3.times do |i|
        @posts << Factory(:post, :published_at => i.hours.ago)
      end
    end

    it "should redirect to the next post" do
      get :next, :id => @posts[1].id
      follow_redirect!
      response.should be_success
      assigns(:object).id.should eql(@posts[2].id)
    end

    it "should redirect to the previous post" do
      get :previous, :id => @posts[1].id
      follow_redirect!
      response.should be_success
      assigns(:object).id.should eql(@posts[0].id)
    end

  end
  
  
  describe "POST /posts/preview" do
    
    it "should show a preview post" do

      # Send post to preview and make sure it renders with posted attributes
      post_atts = {
        :title => "Some cool new post",
        :body => "<p>Some cool new post body text</p>",
        :post_type => "post"
        :state => "publish_now", 
        :published_at => 5.mins.ago.to_s, 
        :location_list=>["blog"],
        :tag_list => "",
        :slug => "", 
        :post_type => "post", 
        :tw_me => "1", 
        :fb_me => "1", 
        :social_msg => ""
      }
      
      # Standard post
      post :preview, :post => post_atts
      response.should be_success
      post_atts.each_pair do |key,val|
        assigns(:object).send(key).should eql(val)
      end

      # Photos post
      post :preview, :post => post_atts.merge({
        :post_type => "photos",
        :display_type => "photos"
      })
      response.should be_success
      

      # Video post
      post :preview, :post => post_atts.merge({
        :post_type => "video"
      })
      response.should be_success

    end
  end
  
  
end