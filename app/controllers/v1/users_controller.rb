class V1::UsersController < V1::AppController

  before_action :set_user, only: :show

  setter_for :user

  def show
    render json: @user, status: :ok
  end

  def profile
    if user_signed_in?
      render json: current_user, serializer: V1::ProfileSerializer, status: :ok
    else
      render json: { error: "you're not signed in" }, status: :not_found
    end
  end

  private

    def default_serializer_options
      { root: false }
    end
end
