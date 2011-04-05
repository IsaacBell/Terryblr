require 'spec_helper'

describe Terryblr::Page do
  
  before do
    @page = Factory(:page)
  end
  
  it "should be valid and create a page" do
    page = Terryblr::Page.new(:state => "pending")
    page.valid?.should eql(true)
    page.save.should eql(true)
  end

  it "should not be valid with missing fields" do
    page = Terryblr::Page.new(:state => "published")
    page.valid?.should eql(false)
    [:title, :slug, :body].each do |col|
      page.errors[col].blank?.should eql(false)
    end
    page.save.should eql(false)
  end

end