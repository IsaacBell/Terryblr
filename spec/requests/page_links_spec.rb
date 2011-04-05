require File.join(File.dirname(__FILE__), '../spec_helper.rb')

describe "PagesLinks" do

  before do
    @site = Terryblr::Site.default
    @page = Factory(:page, :site => @site)
  end
  
  it "should show page at /:page_slug" do
    get "/#{@page.slug}"
    response.should be_success
  end

end