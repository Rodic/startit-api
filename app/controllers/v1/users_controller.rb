class V1::UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    render json: @user, status: :ok
  end

  private

    def default_serializer_options
      { root: false }
    end

end