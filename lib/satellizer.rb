class SatellizerProvider

  def self.for(satellizer_params)
    satellizer_params[:provider].classify.constantize.new(satellizer_params)
  end

  def get_provider_name
    raise NotImplementedError, "Implement it in subclass!"
  end

  def get_uid
    raise NotImplementedError, "Implement it in subclass!"
  end

  def get_username
    raise NotImplementedError, "Implement it in subclass!"
  end

  def get_email
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

  def get_provider_name
    'facebook'
  end

  def get_uid
    get_profile["id"]
  end

  def get_username
    get_profile["name"]
  end

  def get_email
    get_profile["email"]
  end

  private

    def get_profile
      @profile ||= JSON.parse(open(profile_uri).read)
    end

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
