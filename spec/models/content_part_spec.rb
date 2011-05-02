require 'spec_helper'

describe Terryblr::ContentPart do
  describe "validation" do

    before do
      @part = Factory(:content_part)
    end
    
    it "should be valid and create a post with parts" do
      post = Terryblr::ContentPart.new(:state => "text")
      post.valid?.should eql(false)
      post.save.should eql(false)
      post.errors.on(:parts).nil?.should eql(false)
    end

    it "should not be valid with unknown state and post_type" do
      post = Terryblr::Post.new(:state => "unknown")
      post.valid?.should eql(false)
      post.save.should eql(false)
      post.errors.on(:parts).nil?.should eql(false)
    end
    
  end

end
