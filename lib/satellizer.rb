class SatellizerProvider

  def self.for(satellizer_params)
    satellizer_params[:provider].classify.constantize.new(satellizer_params)
  end

  def get_profile
    @profile ||= open(profile_uri).read
  end

  def get_jwt
    { token: JWT.encode(get_profile, Rails.application.secrets.secret_key_base) }
  end

  private

    def profile_uri
      raise NotImplementedError, "Implement it in subclass!"
    end
end


class Facebook < SatellizerProvider

  def initialize(satellizer_params={})
    @params = {
      client_id:     satellizer_params[:clientId]     || ENV['FACEBOOK_APP_ID'],
      client_secret: satellizer_params[:clientSecret] || ENV['FACEBOOK_SECRET'],
      redirect_uri:  satellizer_params[:redirectUri],
      code:          satellizer_params[:code]
    }
  end

  private

    def access_token_uri
      base = "https://graph.facebook.com/oauth/access_token"
      "#{base}#{@params.inject("?") { |acc, p| acc + "#{p[0]}=#{p[1]}&" }}".chop
    end

    def access_token
      open(access_token_uri).read
    end

    def profile_uri
      "https://graph.facebook.com/me?#{access_token}"
    end
end
