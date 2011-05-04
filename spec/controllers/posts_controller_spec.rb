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
      Terryblr::Post.delete_all
      @posts = []
      3.times do |i|
        @posts << Factory(:post, :published_at => i.hours.ago, :site => Terryblr::Site.default)
      end
    end

    it "should redirect to the next post" do
      @posts.all?(&:valid?).should eql(true)
      
      get :next, :id => @posts[1].id
      response.should be_redirect
      response.should redirect_to(post_path(@posts[0], @posts[0].slug))
    end

    it "should redirect to the previous post" do
      get :previous, :id => @posts[1].id
      response.should be_redirect
      response.should redirect_to(post_path(@posts[2], @posts[2].slug))
    end
  end

  describe "POST /posts/preview" do
    it "shows a preview post" do
      # Send post to preview and make sure it renders with posted attributes
      post_atts = Factory.attributes_for(:post_to_be_published_now)
      
      # Standard post
      post :preview, :post => post_atts
      response.should be_success
      post_atts.each_pair do |key, val|
        case key
        when :state
          assigns(:resource).send(key).should eql('published')
        when :published_at
          assigns(:resource).send(key).to_s.should eql(val.to_s)
        else
          assigns(:resource).send(key).should eql(val)
        end
      end

      # Video post
      post :preview, :post => post_atts.merge({
        :post_type => "video"
      })

      response.should be_success
    end
  end
  
end