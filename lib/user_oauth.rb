module UserOauth
  module ClassMethods
  end

  module InstanceMethods
    def oauth_sn
      @oauth_sn ||= ActiveSupport::JSON.decode(RestClient.get(CUSTOM_PROVIDER_URL+"users/#{_user.uid}.json"))
    end

    def sn_name
      oauth_sn["name"]
    end

    def sn_email
      oauth_sn["email"]
    end

    def sn_nickname
      oauth_sn["nickname"]
    end

    def sn_update_attribute(field, value)
      ActiveSupport::JSON.decode(
        RestClient.put(CUSTOM_PROVIDER_URL+"users/#{_user.uid}.json",{:access_token => _user.sn_token, :user => {field.to_sym => value}})

      )
    end

    def _user
      self
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end