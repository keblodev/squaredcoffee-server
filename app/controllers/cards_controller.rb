class CardsController < ApplicationController
	protect_from_forgery with: :null_session

    # todo: currently there's no session verify
    # todo: solve this: protect_from_forgery with: :null_session
    # there are no cookies basically
	# before_filter :authorize

	def initialize
		@access_token = Rails.application.secrets.square_access_token

		SquareConnect.configure do |config|
			# Configure OAuth2 access token for authorization: oauth2
			config.access_token = @access_token
		end
	end

	def new
        customer_card_api = SquareConnect::CustomersApi.new

        puts request.headers.inspect

		customer_card_request = {
			card_nonce: params[:nonce],
			billing_address: {
				address_line_1: '1455 Market St',
				address_line_2: 'Suite 600',
				locality: 'San Francisco',
				administrative_district_level_1: 'CA',
				postal_code: '94103',
				country: 'US'
			},
			cardholder_name: 'Amelia Earhart'
		}

		user = get_user(params[:token])

		customer_id = user[:remote_id]

		begin
			customer_card_response = customer_card_api.create_customer_card(customer_id, customer_card_request)
			puts 'CustomerCard ID to use with Charge:'
			puts customer_card_response.card.id
		rescue SquareConnect::ApiError => e
            raise "Error encountered while creating customer card: #{e.message}"

            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
			return
		end

		customer_card_res = customer_card_response.card

		card = Card.find_or_create_by(
			remote_id: 	customer_card_res.id,
		)
        puts "tst1"
		card.user = user

		if card.save
			session[:card_id] = card.id

			render json: {:status => 200, :data => customer_card_res}
		end
	end

	def get_user(user_auth_token)
		# TODO: do Token model
		# exps and created fields
		@user ||= User.find(session[:user_id]) if session[:user_id] else User.find_by_auth_token(user_auth_token)
	end
end
