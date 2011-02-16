require 'spec_helper'

describe "Terryblr" do
  it "should show pages" do
    { :get => '/terryblr/pages/slug' }.should route_to(:controller => "terryblr/pages", :action => "show", :id => "slug")
  end
end