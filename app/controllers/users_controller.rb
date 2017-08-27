class UsersController < ApplicationController
	def initialize
		@access_token = Rails.application.secrets.square_access_token

		SquareConnect.configure do |config|
			# Configure OAuth2 access token for authorization: oauth2
			config.access_token = @access_token
		end
	end

	def new
		customer_api = SquareConnect::CustomersApi.new
		reference_id = SecureRandom.uuid

		customer_request = {
			given_name: 'Amelia',
			family_name: 'Earhart',
			email_address: 'Amelia.Earhart@example.com',
			address: {
				address_line_1: '500 Electric Ave',
				address_line_2: 'Suite 600',
				locality: 'New York',
				administrative_district_level_1: 'NY',
				postal_code: '10003',
				country: 'US'
			},
			phone_number: '1-555-555-0122',
			reference_id: reference_id,
			note: 'a customer'
		}

		begin
			customer_response = customer_api.create_customer(customer_request)
			puts 'Customer ID to use with CreateCustomerCard:'
			puts customer_response
		rescue SquareConnect::ApiError => e
			raise "Error encountered while creating customer: #{e.message}"
			return
		end

		customer_res = customer_response.customer

		user = User.find_or_create_by({
			# TODO: token class
			auth_token: SecureRandom.uuid,
			remote_id: customer_res.id
		})

		if user.save
			session[:user_id] = user.id

			@current_user = session[:user_id]

			render json: {:status => 200, :data => {token: user.auth_token}}
		else
			get_user
		end
	end
end
