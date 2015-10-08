require 'rails_helper'

RSpec.describe V1::UsersController, type: :controller do

  describe "show" do

    it "renders user when correct id is provided" do
      u = FactoryGirl.create(:user)
      get :show, id: u.id
      expect(response).to have_http_status :ok
      expect(assigns(:user)).to eq(u)
      expect(JSON.parse(response.body)).to eq({
        "id" => u.id,
        "username" => u.username
      })
    end

    it "returns 'not found' when user doesn't exist" do
      get :show, id: 0
      expect(response).to have_http_status :not_found
    end
  end

  describe "profile" do

    describe "signed user" do

      let(:user) { FactoryGirl.create(:user) }

      before :each do
        request.headers["HTTP_AUTHORIZATION"] = "Bearer #{controller.get_auth_jwt(user)}"
      end

      it "renders profile of current_user" do
        get :profile
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({
          "id" => user.id,
          "username"  => user.username,
          "latitude"  => user.latitude.to_s,
          "longitude" => user.longitude.to_s,
          "email"     => user.email,
          "created_events" => user.created_events
        })
      end
    end

    describe "guest" do
      it "returns not_found with helpful message" do
        get :profile
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq({
          "error" => "you're not signed in"
        })
      end
    end
  end
end
