class V1::UsersController < ApplicationController

  before_action :set_user

  def show
    render json: @user, status: :ok
  end

  private

    def set_user
      begin
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end
    end

    def default_serializer_options
      { root: false }
    end
end
