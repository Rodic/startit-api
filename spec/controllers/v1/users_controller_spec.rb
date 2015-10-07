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

end
