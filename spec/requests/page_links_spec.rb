require 'spec_helper'

describe "PagesLinks" do
  before do
    @page = Factory(:page)
  end
  
  it "should have a page at /terryblr/page/slug" do
    get "/terryblr/page/#{@page.to_params}"
    response.should have_selector('h1', :body => "I'm a simple body")
  end
end