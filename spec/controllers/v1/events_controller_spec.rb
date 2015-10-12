require 'rails_helper'

RSpec.describe V1::EventsController, type: :controller do

  describe "index" do

    let!(:asap) { (Time.now + 0.1.second).strftime("%Y %h %d %H:%M:%S.%L") }

    it "lists upcoming events" do
      e1 = FactoryGirl.create(:run, start_time: asap)
      e2 = FactoryGirl.create(:run, start_time: 2.days.from_now)
      e3 = FactoryGirl.create(:bike_ride, start_time: 1.week.from_now)
      e4 = FactoryGirl.create(:bike_ride, start_time: asap)

      sleep(0.2)

      get :index
      expect(assigns(:events)).to contain_exactly(e2, e3)
      expect(response).to be_ok
    end
  end

  describe "show" do

    it "displays specific event when exists" do
      e = FactoryGirl.create(:run)
      get :show, id: e.id
      expect(assigns(:event)).to eq(e)
      expect(response).to have_http_status(:ok)
    end

    it "returns 404 when event doesn't exists" do
      get :show, id: 0
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "create" do

    let(:valid_params) {{
      event: {
        description: "My morning run",
        start_latitude: 44.82,
        start_longitude: 20.45,
        start_time: 1.week.from_now,
        type: 'Run'
      }
    }}

    let(:invalid_params) {{ event: {} }}

    describe "guest" do
      it "fails with valid params" do
        post :create, valid_params
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ "error" => "must be signed in" })
      end
    end

    describe "signed user" do

      let(:user) { FactoryGirl.create(:user) }

      before :each do
        request.headers["HTTP_AUTHORIZATION"] = "Bearer #{controller.get_auth_jwt(user)}"
      end

      it "succeeds when params are valid" do
        expect{ post :create, valid_params }.to change{ Event.count }.from(0).to(1)
        expect(Event.last.description).to eq(valid_params[:event][:description])
        expect(Event.last.start_latitude).to eq(valid_params[:event][:start_latitude])
        expect(Event.last.start_longitude).to eq(valid_params[:event][:start_longitude])
        expect(Event.last.start_time).to be_within(1).of(valid_params[:event][:start_time])
        expect(Event.last.type).to eq(valid_params[:event][:type])
        expect(Event.last.creator).to eq(user)
        expect(response).to have_http_status(:created)
      end

      it "fails when params are invalid" do
        errors = {
          "start_latitude"  => ["can't be blank", "is not a number"],
          "start_longitude" => ["can't be blank", "is not a number"],
          "start_time"  => ["can't be blank"],
          "description" => ["can't be blank"],
          "type" => ["can't be blank", "must be 'Run' or 'BikeRide'"]
        }

        expect{ post :create, invalid_params }.not_to change{ Event.count }
        expect(JSON.parse(response.body)).to eq(errors)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "update" do

    describe "guest" do
      it "fails with valid params" do
        e = FactoryGirl.create(:event, description: "Old description")
        put :update, id: e.id, event: { description: "New description" }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ "error" => "must be signed in" })
      end
    end

    describe "signed in user" do

      let(:user) { FactoryGirl.create(:user) }

      before :each do
        request.headers["HTTP_AUTHORIZATION"] = "Bearer #{controller.get_auth_jwt(user)}"
      end

      it "returns 404 when event doesn't exists" do
        put :update, id: 0, event: { description: "New description" }
        expect(response).to have_http_status(:not_found)
      end

      it "succeed when params are valid and user is creator" do
        e = FactoryGirl.create(:event, creator: user, description: "Old description")
        put :update, id: e.id, event: { description: "New description" }
        expect(Event.find(e.id).description).to eq("New description")
        expect(response).to have_http_status(:ok)
      end

      it "fails when params are valid and user is not creator" do
        user2 = FactoryGirl.create(:user)
        e = FactoryGirl.create(:event, creator: user2, description: "Old description")
        put :update, id: e.id, event: { description: "New description" }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq("error" => "must be event's creator")
      end

      it "fails when params are not valid" do
        e = FactoryGirl.create(:event, creator: user)
        put :update, id: e.id, event: { description: "" }
        expect(JSON.parse(response.body)).to eq({"description" => ["can't be blank"]})
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "destroy" do

    describe "guest" do
      it "fails" do
        e = FactoryGirl.create(:event)
        expect{ delete :destroy, id: e.id }.not_to change{Event.count}
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ "error" => "must be signed in" })
      end
    end

    describe "signed in user" do
      let(:user) { FactoryGirl.create(:user) }

      before :each do
        request.headers["HTTP_AUTHORIZATION"] = "Bearer #{controller.get_auth_jwt(user)}"
      end

      it "returns 404 when event doesn't exists" do
        delete :destroy, id: 0
        expect(response).to have_http_status(:not_found)
      end

      it "succeed when id is valid and user is creator" do
        e = FactoryGirl.create(:event, creator: user)
        expect{ delete :destroy, id: e.id }.to change{Event.count}.by(-1)
        expect(response).to have_http_status(:no_content)
      end

      it "fails when user is not creator" do
        user2 = FactoryGirl.create(:user)
        e = FactoryGirl.create(:event, creator: user2)
        expect{ delete :destroy, id: e.id }.not_to change{Event.count}
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ "error" => "must be event's creator" })
      end
    end
  end
end
