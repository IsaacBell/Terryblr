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

end
