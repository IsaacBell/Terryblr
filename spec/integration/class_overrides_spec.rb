require 'spec_helper'

describe "Class overrides" do

  it "Dummy::Post should have been inserted in Terryblr::Post" do
    Terryblr::Post.hello.should eq("World ! (from Post.hello)")
    post = Terryblr::Post.new 
    post.greet.should eq("Hey you ! (from Post#greet)")
  end
  
  it "Dummy::PostController shoud have been inserted in Terryblr::PostController" do
    Terryblr::PostsController.new.should respond_to 'greet'
  end
end
