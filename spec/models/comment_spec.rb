require 'spec_helper'

describe Terryblr::Comment do
  
  it "should be dropped if considered as spam" do
    comment = Terryblr::Comment.new(Factory.attributes_for(:comment))
    comment.stub!(:spam?).and_return true
    comment.save
    comment.errors.should_not be_empty
  end
  
end