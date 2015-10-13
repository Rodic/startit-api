require 'rails_helper'

RSpec.describe V1::ParticipationsController, type: :controller do

  describe "create" do

    describe "signed user" do

      let(:user) { FactoryGirl.create(:user) }

      before :each do
        request.headers["HTTP_AUTHORIZATION"] = "Bearer #{controller.get_auth_jwt(user)}"
      end

      it "creates participation when event exists" do
        e = FactoryGirl.create(:event)
        expect{ post :create, participation: { event_id: e.id } }.to change{ Participation.count }.from(0).to(1)
        expect(response).to have_http_status(:created)
      end

      it "fails when event not provided" do
        expect{ post :create, participation: {} }.not_to change{ Participation.count }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ "event_id" => [ "can't be blank" ] })
      end

      it "fails when event doesn't exist" do
        expect{ post :create, participation: { event_id: 0 } }.not_to change{ Participation.count }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ "event_id" => [ "doesn't exist" ] })
      end
    end

    describe "guest" do
      it "fails with valid params" do
        e = FactoryGirl.create(:event)
        expect{ post :create, participation: { event_id: e.id } }.not_to change{ Participation.count }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ "error" => "must be signed in" })
      end
    end
  end

end
