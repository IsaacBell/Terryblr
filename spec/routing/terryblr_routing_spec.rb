require 'spec_helper'

describe "TerryBlr" do
  it "should get new account at /terryblr/accounts/new" do
    { :get => '/terryblr/accounts/new' }.should route_to(:controller => "terryblr/accounts", :action => "new")
  end

  it "should create account" do
    { :post => '/terryblr/accounts' }.should route_to(:controller => "terryblr/accounts", :action => "create")
  end
end