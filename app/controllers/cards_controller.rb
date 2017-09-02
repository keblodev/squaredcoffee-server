require 'json'

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

        # puts request.headers.inspect

		user = get_user(params[:token])

        customer_id = user[:remote_id]

        remote_user = get_remote_user(customer_id)

		customer_card_request = {
			card_nonce: params[:nonce],
			billing_address: {
				address_line_1: remote_user.customer.address.address_line_1,
				address_line_2: remote_user.customer.address.address_line_2,
				locality: remote_user.customer.address.locality,
				administrative_district_level_1: remote_user.customer.address.administrative_district_level_1,
				postal_code: remote_user.customer.address.postal_code,
				country: remote_user.customer.address.country,
			},
			cardholder_name: "#{remote_user.customer.given_name} #{remote_user.customer.family_name}"
		}

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

        card.user = user

		if card.save
			session[:card_id] = card.id

			render json: {:status => 200, :data => customer_card_res}
		end
    end

    def delete
		user = get_user(params[:token])

        customer_card_id = params[:remote_card_id]
        customer_id = user[:remote_id]

        begin
            api = SquareConnect::CustomersApi.new
            api.delete_customer_card(customer_id, customer_card_id)
        rescue SquareConnect::ApiError => e
            raise "Error encountered while deleting customer card: #{e.message}"

            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
            return false
        end

        render json: {:status => 200}
    end

    def get
        customer_card_api = SquareConnect::CustomersApi.new

		user = get_user(params[:token])

        customer_id = user[:remote_id]

        remote_user = get_remote_user(customer_id)

        puts remote_user
        puts remote_user.customer.cards

        render json: {:status => 200, :data => remote_user.customer.cards}
    end

	def get_user(user_auth_token)
		# TODO: do Token model
		# exps and created fields
		@user ||= User.find(session[:user_id]) if session[:user_id] else User.find_by_auth_token(user_auth_token)
    end

    def get_remote_user(remote_id)
        begin
            api = SquareConnect::CustomersApi.new
            return api.retrieve_customer(remote_id)
        rescue SquareConnect::ApiError => e
            raise "Error encountered while retreaving customer: #{e.message}"

            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
            return false
        end
    end
end
