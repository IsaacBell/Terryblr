class Terryblr::AccountsController < ApplicationController

  unloadable

  def new
    @account = Account.new
  end

  def create
    puts "Do nothing"
  end

end