require 'rails_helper'

RSpec.describe V1::SessionsController, type: :controller do

  describe "create" do
    before do
      provider = double("provider")
      allow(SatellizerProvider).to receive(:for).and_return(provider)
      allow(provider).to receive(:get_jwt).and_return({ "token" => "12345" })
    end

    it "renders token" do
      post :create, provider: 'facebook'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ "token" => "12345" })
    end
  end
end
