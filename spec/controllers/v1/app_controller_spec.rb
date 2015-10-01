require 'rails_helper'

RSpec.describe V1::AppController, type: :controller do


  describe "current_user" do

    controller do
      def index
        @cu = current_user
        head status: :ok
      end
    end

    it "returns nil when no authorization header is provided" do
      get :index
      expect(assigns(:cu)).to be_nil
    end

    it "returns singed user when valid authorization header is present" do
      user = FactoryGirl.create(:user)
      token = JWT.encode({ id: user.id }, Rails.application.secrets.secret_key_base)

      request.headers["HTTP_AUTHORIZATION"] = "Bearer #{token}"
      get :index

      expect(assigns(:cu)).to eq(user)
    end

    it "returns nil when invalid authorization header is present" do
      request.headers["HTTP_AUTHORIZATION"] = "XXXXXXXX"
      get :index

      expect(assigns(:cu)).to be_nil
    end
  end

end
