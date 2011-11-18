require 'omniauth/oauth'
require 'multi_json'
CUSTOM_PROVIDER_URL = (Rails.env == 'production' ? 'http://oauthsn-dev.heroku.com/' : 'http://localhost:3009/')
module OmniAuth
 module Strategies

   class OauthSn < OAuth2

    def initialize(app, api_key = nil, secret_key = nil, options = {}, &block)
      client_options = {
        :site =>  CUSTOM_PROVIDER_URL,
        :authorize_url => "#{CUSTOM_PROVIDER_URL}/auth/oauth_sn/authorize",
        :access_token_url => "#{CUSTOM_PROVIDER_URL}/auth/oauth_sn/access_token"
      }
      super(app, :oauth_sn, api_key, secret_key, client_options, &block)
    end

protected

    def user_data
      @data ||= MultiJson.decode(@access_token.get("/auth/oauth_sn/user.json"))
    end

    def request_phase
      options[:scope] ||= "read"
      super
    end

    def user_hash
      user_data
    end

    def auth_hash
      OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data["uid"],
          'user_info' => {
              'email' => user_data["user_info"]['email'],
              'name' => user_data["user_info"]['name'],
              'nickname' => user_data["user_info"]['nickname'],
          }
      })
    end
   end
 end
end
