require 'spec_helper'

describe Account do
  it "should create a new account instance given valid attributes" do
    attrs = { :uname => "The title of the account", :fake => "##Welcome to Mero CMS" }
    account = Account.new(attrs)
    account.should be_valid

    account.save!
    account.uname.should eq "The title of the account"
  end
end