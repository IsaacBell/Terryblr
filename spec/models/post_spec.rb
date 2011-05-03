require 'spec_helper'

describe Terryblr::Post do
  describe "validation" do
    before do
    end

    it "should be valid and create a post with parts" do
      post = Terryblr::Post.new(:state => "pending")
      post.valid?.should eql(false)
      post.save.should eql(false)
      post.errors[:parts].nil?.should eql(false)
      
      post.parts << Factory(:content_part_text)
      post.valid?.should eql(true)
      post.save.should eql(true)
      
    end

    it "should not be valid with unknown state and post_type" do
      post = Terryblr::Post.new(:state => "unknown")
      post.valid?.should eql(false)
      post.save.should eql(false)
      post.errors[:state].nil?.should eql(false)
      post.errors[:parts].nil?.should eql(false)
    end
    
    it "should create a post from content-part attributes" do
      parts = [Factory(:content_part_text), Factory(:content_part_photos), Factory(:content_part_videos)]
      post = Terryblr::Post.new(:title => "test post with parts", :state => "drafted", :part_ids => parts.map(&:id), :parts_attributes => parts.map(&:attributes))
      post.valid?.should eql(true)
      post.save.should eql(true)
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
