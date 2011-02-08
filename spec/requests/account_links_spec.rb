require 'spec_helper'

describe "AccountsLinks" do
  it "should have a new account page at /terryblr/accounts/new" do
    get '/terryblr/accounts/new'
    response.should have_selector('h1', :content => "Hello, world!")
  end
end