require 'spec_helper'

describe "PagesLinks" do
  before do
    @page = Factory(:page)
  end
  
  it "should show page at /:pages_slug" do
    get "/#{@page.slug}"
    response.should be_success
  end
end