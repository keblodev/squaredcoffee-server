require 'jwt'
# require 'promise'

module TokenHelper

    def self.sign_verify_email(email)
        hmac_secret = Rails.application.secrets["tokens"]["verify_email_token"]
        JWT.encode({"email" => email, "exp" => Time.now.to_i() + 60*60}, hmac_secret, 'HS256')
    end

    def self.sign_remove_email(email)
        hmac_secret = Rails.application.secrets["tokens"]["remove_email_token"]
        return JWT.encode({ "email" => email, "exp" => Time.now.to_i() + 60*60 }, hmac_secret, 'HS256');
    end

    def self.sign_reset_email(email)
        hmac_secret = Rails.application.secrets["tokens"]["reset_password_token"]
        return JWT.encode(
            { "email" => email, "exp" => Time.now.to_i() + 60*60 }, hmac_secret, 'HS256'
        );
    end

    def self.verify_email_token(token, secretEmailToken)
        JWT.decode token, secretEmailToken
    end

end
