require 'spec_helper'

describe "Terryblr" do
  it "should show pages" do
    { :get => '/terryblr/pages' }.should route_to(:controller => "terryblr/pages", :action => "show")
  end
end