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
      client_id:     satellizer_params[:clientId]     || ENV["FACEBOOK_APP_ID"],
      client_secret: satellizer_params[:clientSecret] || ENV["FACEBOOK_SECRET"],
      redirect_uri:  satellizer_params[:redirectUri],
      code:          satellizer_params[:code]
    }
  end

  def get_provider_name
    "facebook"
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
#
# {
#   "access_token" : "ya29.BAI48PrTDNABgAdPuJo5W4TUwGo_zy8Bv6ffL-_aIvryvc5j6lruKvcuOA8-RU796zhI",
#   "token_type" : "Bearer",
#   "expires_in" : 3600,
#   "id_token" : "eyJhbGciOiJSUzI1NiIsImtpZCI6IjdhNTE4YThiZjI1MzFlNWJlNzQwMTc1ZWEyMDU5ZjBiYWQ5ZGUyZmUifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiYXRfaGFzaCI6Ims4NUpHX2E0aGR0azA1MFBBNE1waGciLCJhdWQiOiI0OTY5NTA4NTMwMzYtbWgwamYyZjEzbXRjNGgwcjQ3YWtjYXRpNnNzZmZ1NXEuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDU1ODUzOTQwOTkxNzYzMTU5MjYiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiNDk2OTUwODUzMDM2LW1oMGpmMmYxM210YzRoMHI0N2FrY2F0aTZzc2ZmdTVxLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiZW1haWwiOiJhbGVjLnJvZGljQGdtYWlsLmNvbSIsImlhdCI6MTQ0NDE1MzkxNSwiZXhwIjoxNDQ0MTU3NTE1fQ.QtZG887Dvqudw0-98m0y7Fh6Kt0K8xkPq2wMkNMbnhaCJosrkYBIglXHyIqo2vtz-9Mn7TV5ibtuLIKBBSZJL7WWgdWJqH5ZMhZmO3ReTS_N9NeBiAEbWqu29d9t4lzUhxvCmjSZBHH4U1ju2fdE91rDXZUiLiqKj_WvXK0CD-bjxRnfClIx3qDLqNyaGh2qpWpsXjCW_7dT32y6NqJEESfieHmBny3ccDQSGWzlKAoMjZyU1mMXgOXM0XBy-GewWBumOJE3vm3Ht4mwIKnPsulSVMj7GiIUUJ2j4eXsIvdV0GCro6mfpbNqIMt88aTzs-tH6IlrHpQlZe-oz98tDg"
# }

class Google < SatellizerProvider

  def initialize(satellizer_params={})
    @params = {
      grant_type:    "authorization_code",
      client_id:     satellizer_params[:clientId],
      client_secret: ENV["GOOGLE_SECRET"],
      redirect_uri:  satellizer_params[:redirectUri],
      code:          satellizer_params[:code]
    }
  end

  def get_provider_name
    "google"
  end

  def get_uid
    get_profile["id"]
  end

  def get_username
    get_profile["displayName"]
  end

  def get_email
    get_profile["emails"][0]["value"]
  end

  private

    def access_token_uri
      "https://www.googleapis.com/oauth2/v3/token"
    end

    def access_token
      uri = URI.parse(access_token_uri)
      response = Net::HTTP.post_form(uri, @params)
      JSON.parse(response.body)["access_token"]
    end

    def get_profile
      @profile ||= JSON.parse(open(profile_uri).read)
    end

    def profile_uri
      "https://www.googleapis.com/plus/v1/people/me?access_token=#{access_token}"
    end
end
