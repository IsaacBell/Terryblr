module Terryblr
  class AccountsController < ApplicationController
    
    unloadable

    def create
      puts "Do nothing"
    end

    def new
      @account = Account.new
    end

  end
end
