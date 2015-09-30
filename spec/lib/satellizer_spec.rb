require 'rails_helper'
require 'satellizer'

describe "SatellizerProvider" do

  describe "for" do
    it "returns Facebook when 'facebook' is provided in params" do
      expect(SatellizerProvider.for(provider: 'facebook')).to be_an_instance_of(Facebook)
    end

    it "raises error when provider is unknown" do
      expect{ SatellizerProvider.for(provider: 'unknown_provider') }.to raise_error(
        NameError, /uninitialized constant UnknownProvider/
      )
    end
  end

  describe "Facebook" do

    let(:satellizer_params)   {{ clientId:  '1', clientSecret:  'secret', redirectUri:  'www.example.com', code: 'A' }}
    let(:access_token_params) {{ client_id: '1', client_secret: 'secret', redirect_uri: 'www.example.com', code: 'A' }}

    let(:facebook) { Facebook.new(satellizer_params) }

    before do
      stub_request(:get, "https://graph.facebook.com/oauth/access_token")
        .with(query: access_token_params)
        .to_return(body: "access_token=12345")

      stub_request(:get, "https://graph.facebook.com/me")
        .with(query: { access_token: "12345" })
        .to_return(body: '{"name":"John Doe","id":"1234567891234567"}')
    end


    describe "access_token_uri" do

      it "turns hash params into url" do
        expect(facebook.send(:access_token_uri)).to eq(
        "https://graph.facebook.com/oauth/access_token?client_id=1&client_secret=secret&redirect_uri=www.example.com&code=A"
        )
      end

      it "when no client_id and client_secret are provided through params they are read from ENV vars" do
        facebook = Facebook.new
        expect(facebook.send(:access_token_uri)).to match /client_id=.+&/
        expect(facebook.send(:access_token_uri)).to match /&client_secret=.+&/
      end
    end

    describe "access_token" do
      it "returns access_token from facebook" do
        expect(facebook.send(:access_token)).to eq("access_token=12345")
      end
    end

    describe "profile_uri" do
      it "forms correct uri" do
        expect(facebook.send(:profile_uri)).to eq("https://graph.facebook.com/me?access_token=12345")
      end
    end

    describe "get_profile" do
      it "returns correct data" do
        expect(facebook.get_profile).to eq('{"name":"John Doe","id":"1234567891234567"}')
      end
    end


    describe "get_jwt" do

      it "returns correct token" do
        expect(facebook.get_jwt).to eq(
          {:token => "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.IntcIm5hbWVcIjpcIkpvaG4gRG9lXCIsXCJpZFwiOlwiMTIzNDU2Nzg5MTIzNDU2N1wifSI.e7cZVC_qYx-PllUGRlHqk-3FUAGLoQ_sjg1m5WEbjgs"}
        )
      end

      it "gets verified with rails secret_key_base" do
        expect{ JWT.decode(facebook.get_jwt[:token], Rails.application.secrets.secret_key_base, true) }.not_to raise_error
      end
    end
  end
end
