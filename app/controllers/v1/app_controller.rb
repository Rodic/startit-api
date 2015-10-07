class V1::AppController < ApplicationController

  def current_user
    @current_user || get_user_from_auth_token
  end

  def user_signed_in?
    !current_user.nil?
  end

  def forbidden_for_guest
    render json: { error: "must be signed in" }, status: :unauthorized unless user_signed_in?
  end

  def get_auth_jwt(user)
    get_jwt({ iss: "start.it", id: user.id })
  end

  def self.setter_for(record)
    define_method "set_#{record}" do
      begin
        instance_variable_set("@#{record}", record.to_s.classify.constantize.find(params[:id]))
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end
    end
  end

  private

    def get_jwt(payload)
      JWT.encode(payload, Rails.application.secrets.secret_key_base)
    end

    def get_user_from_auth_token
      jwt_token = (request.headers["HTTP_AUTHORIZATION"] || "").sub("Bearer ", "")
      begin
        jwt_decoded = JWT.decode(jwt_token, Rails.application.secrets.secret_key_base, true)
        user_id = jwt_decoded.first["id"]
        @current_user = User.where(id: user_id).first
      rescue JWT::VerificationError, JWT::DecodeError
        nil
      end
    end
end
