require 'spec_helper'

describe 'Terryblr' do
  it 'should show homepage' do
    { :get => '/' }.should route_to(:controller => 'terryblr/home', :action => 'index')
  end

  it 'should display posts tagged by :tag' do
    { :get => '/posts/tagged/a_tag' }.should route_to(:controller => 'terryblr/posts', :action => 'tagged', :tag => 'a_tag')
  end

  it 'should display post archives' do
    { :get => '/posts/archives' }.should route_to(:controller => 'terryblr/posts', :action => 'archives')
  end

  it 'should display post' do
    { :get => '/posts/1/post_slug' }.should route_to(:controller => 'terryblr/posts', :action => 'show', :id => '1', :slug => 'post_slug')
  end

  it 'should search for document' do
    { :get => '/search?search=SEARCH' }.should route_to(:controller => 'terryblr/home', :action => 'search')
  end

  it 'should display robots.txt' do
    { :get => '/robots.txt' }.should route_to(:controller => 'terryblr/home', :action => 'robots', :format => 'txt')
  end

  it 'should return error 404 page' do
    { :get => '/404' }.should route_to(:controller => 'terryblr/home', :action => 'not_found')
  end

  it 'should return error 500 page' do
    { :get => '/500' }.should route_to(:controller => 'terryblr/home', :action => 'error')
  end

  it 'should show page identified by its slug' do
    { :get => '/page_slug' }.should route_to(:controller => 'terryblr/pages', :action => 'show', :page_slug => 'page_slug')
  end
end