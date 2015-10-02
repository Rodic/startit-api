require 'rails_helper'

RSpec.describe V1::SessionsController, type: :controller do

  describe "create" do

    let(:provider_name) { "facebook" }
    let(:username)      { "John Doe" }
    let(:uid)           { 1 }

    before do
      provider = double("provider")
      allow(SatellizerProvider).to receive(:for).and_return(provider)
      allow(provider).to receive(:get_provider_name).and_return(provider_name)
      allow(provider).to receive(:get_uid).and_return(uid)
      allow(provider).to receive(:get_username).and_return(username)
      allow(provider).to receive(:get_email).and_return(nil)
    end

    it "creates new record if user is new" do
      expect{ post :create, provider: provider_name }.to change{ User.count }.from(0).to(1)
    end

    it "returns existing user if it exists" do
      FactoryGirl.create(:user, provider: provider_name, uid: uid, username: username)
      expect{ post :create, provider: provider_name }.not_to change{ User.count }
    end

    it "renders token" do
      expect{ post :create, provider: provider_name }.to change{ User.count }.from(0).to(1)
      id = User.last.id
      expect(JSON.parse(response.body)).to eq(
        { "token" => controller.get_jwt(id: id) }
      )
    end
  end
end
