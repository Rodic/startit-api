class V1::UsersController < V1::AppController

  before_action :set_user

  setter_for :user

  def show
    render json: @user, status: :ok
  end

  private

    def default_serializer_options
      { root: false }
    end
end
