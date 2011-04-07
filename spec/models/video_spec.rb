require 'spec_helper'

describe Terryblr::Video do
  describe "validation" do
    before do
      @post = Factory(:published_post)
    end

    it "should update associated post on create" do
      video = Factory.build(:video, :post => @post)
      video.stub(:upload_video).and_return(true)
      @post.should_receive(:touch)
      video.save
    end

    it "should update associated post on update" do
      video = Factory.build(:video)
      video.stub(:upload_video).and_return(true)
      video.save
      video.post = @post
      @post.should_receive(:touch)
      video.save
    end
  end
end