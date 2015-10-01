require 'satellizer'

class V1::SessionsController < ApplicationController

  def create
    provider = SatellizerProvider.for(params)

    user = User.find_or_create_by(provider: provider.get_provider_name, uid: provider.get_uid) do |u|
      u.username = provider.get_username
      u.email    = provider.get_email
    end

    satellizer_token = JWT.encode({id: user.id}, Rails.application.secrets.secret_key_base)
    render json: { token: satellizer_token }, status: :ok
  end
end
