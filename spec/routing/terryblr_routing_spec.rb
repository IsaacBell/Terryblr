require 'spec_helper'

describe "Terryblr" do

  it "should show homepage" do
    { :get => '/' }.should route_to(:controller => "terryblr/home", :action => "index")
  end

  it "should show page identified by its slug" do
    { :get => '/page_slug' }.should route_to(:controller => "terryblr/pages", :action => "show", :page_slug => "page_slug")
  end
end