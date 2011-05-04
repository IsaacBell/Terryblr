require 'spec_helper'

describe "Dummy app overrides" do
  describe "in Dummy::Post" do
    it "inserts #hello in Terryblr::Post" do
      Terryblr::Post.hello.should eq("World ! (from Post.hello)")
    end

    it "inserts .greet in Terryblr::Post" do
      post = Terryblr::Post.new 
      post.greet.should eq("Hey you ! (from Post#greet)")
    end
  end

  describe "in Dummy::PostController" do
    it "inserted .greet in Terryblr::PostController" do
      Terryblr::PostsController.new.should respond_to 'greet'
    end
  end
end