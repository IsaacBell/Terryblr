require 'spec_helper'

describe "PagesLinks" do
  it "should have a page at /terryblr/page" do
    get '/terryblr/page'
    response.should have_selector('h1', :content => "Hello, world!")
  end
end