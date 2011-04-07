require 'spec_helper'

describe Terryblr::Post do
  describe "validation" do
    before do
      @post = Factory(:post)
    end
    
    it "should be valid and create a post" do
      post = Terryblr::Post.new(:state => "pending", :post_type => "photos")
      post.valid?.should eql(true)
      post.save.should eql(true)
    end

    it "should not be valid with unknown state and post_type" do
      post = Terryblr::Post.new(:state => "unknown", :post_type => "weird")
      post.valid?.should eql(false)
      post.save.should eql(false)
    end
    
  end
  
  describe "next & previous" do
    
    
    before do
      Terryblr::Post.delete_all
      @posts = []
      3.times do |i|
        @posts << Factory(:post, :published_at => i.hours.ago, :site => Terryblr::Site.default)
      end
    end

    it "should be the previous post" do
      @posts[1].previous.id.should eql(@posts[2].id)
    end

    it "should be the next post" do
      @posts[1].next.id.should eql(@posts[0].id)
    end


  end

end
