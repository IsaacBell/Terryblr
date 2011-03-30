require_relative '../spec_helper.rb'

describe "Photos" do

  before do
    @post = Factory(:photos_post)
  end
  
  @selenium
  it "should support the photo upload", :js => true do
    url = edit_admin_post_path(@post)
    puts "url: #{url}"
    visit url
  end

end