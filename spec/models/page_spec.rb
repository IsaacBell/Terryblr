require 'spec_helper'

describe Terryblr::Page do
  
  before do
    @page = Factory(:page)
  end
  
  it "should be valid and create a page" do
    page = Terryblr::Post.new(:state => "pending")
    page.valid?.should eql(true)
    page.save.should eql(true)
  end

  it "should not be valid with unknown state and page_type" do
    page = Terryblr::Post.new(:state => "unknown")
    page.valid?.should eql(false)
    page.save.should eql(false)
  end
  
  
end