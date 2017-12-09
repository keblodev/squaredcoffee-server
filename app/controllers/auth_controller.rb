
class AuthController < ApplicationController

    def password_reset
    end

    def password_reset_action
        if token = params[:token]
            begin
                decoded = TokenHelper.verify_email_token(token, Rails.application.secrets["tokens"]["reset_password_token"])
            rescue Exception => e
                # raise "Error on get_item: #{e.message}"

                render :file => "#{Rails.root}/public/500.html",  :status => 500
                return
            end

            if user = User.find_by_email(decoded.first["email"])
                user.password   = params[:password]
                user.auth_token = SecureRandom.uuid
                user.save
            else
                render :file => "#{Rails.root}/public/404.html",  :status => 404
            end
            render :file => "#{Rails.root}/public/200.html",  :status => 200
        else
            render :file => "#{Rails.root}/public/422.html",  :status => 422
        end
    end

    def validate_email
        if token = params[:token]
            begin
                decoded = TokenHelper.verify_email_token(token, Rails.application.secrets["tokens"]["verify_email_token"])
            rescue HTTP::ResponseError => e
                raise "Error on get_item: #{e.message}"

                render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
                return
            end

            if user = User.find_by_email(decoded.first["email"])
                user.is_verified = true
                user.save
            else
                render :file => "#{Rails.root}/public/404.html",  :status => 404
            end
            render :file => "#{Rails.root}/public/200.html",  :status => 200
        else
            render :file => "#{Rails.root}/public/422.html",  :status => 422
        end
    end

    def invalidate_email
        if token = params[:token]
            begin
                decoded = TokenHelper.verify_email_token(token, Rails.application.secrets["tokens"]["remove_email_token"])
            rescue HTTP::ResponseError => e
                raise "Error on get_item: #{e.message}"

                render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
                return
            end

            if user = User.find_by_email(decoded.first["email"])
                if user.is_verified
                    render :file => "#{Rails.root}/public/404.html",  :status => 404
                else
                    user.destroy
                end
            else
                render :file => "#{Rails.root}/public/404.html",  :status => 404
            end
            render :file => "#{Rails.root}/public/200.html",  :status => 200
        else
            render :file => "#{Rails.root}/public/422.html",  :status => 422
        end
    end

	def get_user(user_auth_token)
		User.find_by_auth_token(user_auth_token) or not_found
	end

    def not_found
        raise ActionController::RoutingError.new('Not Found')
    end
end
