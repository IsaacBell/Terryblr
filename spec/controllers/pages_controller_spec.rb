require 'spec_helper'

describe Terryblr::PagesController do
  describe "GET /pages/show" do
    it "should log the page view, with author and tag data, to google analytics" do
      @page = Factory(:published_page)
      @analytical = mock("analytical")
      controller.stub!(:analytical).and_return(@analytical)
      @analytical.should_receive(:custom_event).with('Tag', 'view', 'a_tag')
      @analytical.should_receive(:custom_event).with('Tag', 'view', 'another_tag')
      @analytical.should_receive(:custom_event).with('Author', 'view', @page.author.email)

      get :show, :page_slug => @page.slug
      response.should be_success
    end
  end

end