require 'satellizer'

class V1::SessionsController < V1::AppController

  def create
    provider = SatellizerProvider.for(params)

    user = User.find_or_create_by(provider: provider.get_provider_name, uid: provider.get_uid) do |u|
      u.username = provider.get_username
      u.email    = provider.get_email
    end

    satellizer_token = get_auth_jwt(user)
    render json: { token: satellizer_token }, status: :ok
  end
end
