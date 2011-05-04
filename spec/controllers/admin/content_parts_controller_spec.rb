require 'spec_helper'

describe Admin::Terryblr::ContentPartsController do

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in Factory.create(:user_admin)
  end

  describe "GET new" do
    describe "with valid params" do
      it "returns a form in JS" do
      end
    end

    describe "with invalid params" do
      it "returns an error message in JS" do
      end
    end
  end

  describe "POST reorder" do
    describe "with valid reorder params" do
      it "updates the parts display order" do
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested part" do
      # Terryblr::Post.stub(:find).with("37") { mock_post }
      # mock_post.should_receive(:destroy)
      # delete :destroy, :id => "37"
    end
  end
end