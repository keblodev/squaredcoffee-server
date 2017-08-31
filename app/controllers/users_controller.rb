class UsersController < ApplicationController
	protect_from_forgery with: :null_session

	def initialize
		@access_token = Rails.application.secrets.square_access_token

		SquareConnect.configure do |config|
			# Configure OAuth2 access token for authorization: oauth2
			config.access_token = @access_token
		end
	end

	def new_remote
		customer_api = SquareConnect::CustomersApi.new
		reference_id = SecureRandom.uuid

        if session[:user_id] == nil
            session[:user_id] = User.find_by_auth_token(params[:token]).id
        end

		customer_request = {
			given_name: params[:given_name],
			family_name: params[:family_name],
			email_address: params[:email_address],
			address: {
				address_line_1: params[:address_line_1],
				address_line_2: params[:address_line_2],
				locality: params[:locality],
				administrative_district_level_1: params[:administrative_district_level_1],
				postal_code: params[:postal_code],
				country: params[:country]
			},
			phone_number: params[:phone_number],
			reference_id: reference_id,
			note: 'a customer'
		}

		begin
			customer_response = customer_api.create_customer(customer_request)
			puts 'Customer ID to use with CreateCustomerCard:'
			puts customer_response
		rescue SquareConnect::ApiError => e
            raise "Error encountered while creating customer: #{e.message}"

            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
			return
		end

		customer_res = customer_response.customer


		user = User.update(
            session[:user_id],
			# TODO: token class
			remote_id: customer_res.id
		)

		if user.save
			session[:user_id] = user.id

			render json: {:status => 200, :data => {
                token: user.auth_token,
                remoteAuthorized: true
            }}
		else
            render :json => {:error => '[user|new_remote]: too bad'}, :status => 500
		end
	end

	def new
		puts params
		user = User.new({
			email: params[:email],
			password: params[:password],
			password_confirmation: params[:password_confirmation],
			auth_token: SecureRandom.uuid
		})
		if user.save
			session[:user_id] = user.id
			render json: {:status => 200, :data => {token: user.auth_token}}
		else
			render :json => {:error => '[user|new]: too bad'}, :status => 500
		end
	end
end
