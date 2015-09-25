require 'rails_helper'

RSpec.describe V1::EventsController, type: :controller do

  describe "index" do

    it "lists upcoming events" do
      e1 = FactoryGirl.create(:event, start_time: 0.1.seconds.from_now)
      e2 = FactoryGirl.create(:event, start_time: 2.days.from_now)
      e3 = FactoryGirl.create(:event, start_time: 1.week.from_now)
      e4 = FactoryGirl.create(:event, start_time: 0.1.seconds.from_now)

      sleep(0.2)

      get :index
      expect(assigns(:events)).to contain_exactly(e2, e3)
      expect(response).to be_ok
    end
  end

  describe "show" do

    it "displays specific event when exists" do
      e = FactoryGirl.create(:event)
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

    it "succeed when params are valid" do
      params = {
        event: {
          description: "My morning run",
          start_latitude: 44.82,
          start_longitude: 20.45,
          start_time: 1.week.from_now
        }
      }

      expect(Event.count).to eq(0)

      post :create, params

      expect(Event.last.description).to eq(params[:event][:description])
      expect(Event.last.start_latitude).to eq(params[:event][:start_latitude])
      expect(Event.last.start_longitude).to eq(params[:event][:start_longitude])
      expect(Event.last.start_time).to be_within(1).of(params[:event][:start_time])

      expect(response).to have_http_status(:created)
    end

    it "fails when params are invalid" do
      params = { event: {} }
      errors = {
        "start_latitude"  => ["can't be blank", "is not a number"],
        "start_longitude" => ["can't be blank", "is not a number"],
        "start_time"  => ["can't be blank"],
        "description" => ["can't be blank"]
      }

      expect{ post :create, params }.not_to change{ Event.count }

      post :create, params
      expect(JSON.parse(response.body)).to eq(errors)
      expect(response).to have_http_status(:unprocessable_entity)
    end

  end

  describe "update" do

    it "returns 404 when event doesn't exists" do
      put :update, id: 0, event: { description: "New description" }
      expect(response).to have_http_status(:not_found)
    end

    it "succeed when params are valid" do
      e = FactoryGirl.create(:event, description: "Old description")
      put :update, id: e.id, event: { description: "New description" }
      expect(Event.find(e.id).description).to eq("New description")
      expect(response).to have_http_status(:ok)
    end

    it "fails when params are not valid" do
      e = FactoryGirl.create(:event)
      put :update, id: e.id, event: { description: "" }
      expect(JSON.parse(response.body)).to eq({"description" => ["can't be blank"]})
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "destroy" do
    
    it "returns 404 when event doesn't exists" do
      delete :destroy, id: 0
      expect(response).to have_http_status(:not_found)
    end

    it "succeed when id is valid" do
      e = FactoryGirl.create(:event)
      expect{ delete :destroy, id: e.id }.to change{Event.count}.by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
