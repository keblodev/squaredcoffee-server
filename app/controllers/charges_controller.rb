PRODUCT_COST = {
  "001" => 100,
  "002" => 4900,
  "003" => 500000
}

class ChargesController < ApplicationController
	protect_from_forgery with: :null_session

	def initialize
		@access_token = Rails.application.secrets.square_access_token

		SquareConnect.configure do |config|
			# Configure OAuth2 access token for authorization: oauth2
			config.access_token = @access_token
		end
	end

	def get_location
		# TODO: Location Model and to session
		locations_api = SquareConnect::LocationsApi.new

		begin
			locations_response = locations_api.list_locations
			puts locations_response
		rescue SquareConnect::ApiError => e
            raise "Error encountered while listing locations: #{e.message}"
            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
            return
		end

		# Get a location able to process transaction
		location = locations_response.locations.detect do |l|
			unless l.capabilities.nil?
				l.capabilities.include?("CREDIT_CARD_PROCESSING")
			end
		end

		if location.nil?
			raise "Activation required.
				Visit https://squareup.com/activate to activate and begin taking payments."
		end

		location
	end

	def charge_card_saved
		# Assume you have correct values assigned to the following variables:
		location = self.get_location
		#   customer
		#   customer_card
		# See the above code samples for how to obtain them.

		transaction_api = SquareConnect::TransactionsApi.new

		# Every payment you process for a given business hae a unique idempotency key.
		# If you're unsure whether a particular payment succeeded, you can reattempt
		# it with the same idempotency key without worrying about double charging
		# the buyer.

		idempotency_key = SecureRandom.uuid

		# Monetary amounts are specified in the smallest unit of the applicable currency.
		# This amount is in cents. It's also hard-coded for $1, which is not very useful.

		amount_money = { :amount => 101, :currency => 'USD' }

		user = get_user(params[:token])

        customer_id = user[:remote_id]

        remote_user = get_remote_user(customer_id);

		transaction_request = {
			:customer_id => user[:remote_id],
			:customer_card_id => params[:customer_card_id],
			:amount_money => amount_money,
			:idempotency_key => idempotency_key
		}

		# The SDK throws an exception if a Connect endpoint responds with anything besides 200 (success).
		# This block catches any exceptions that occur from the request.
		begin
			transaction_response = transaction_api.charge(location.id, transaction_request)
		rescue SquareConnect::ApiError => e
            raise "Error encountered while charging card: #{e.message}"
            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
			return
		end

		puts transaction_response

		render json: {:status => 200, :resp => transaction_response}
	end

	def charge_card_web
		transactions_api = SquareConnect::TransactionsApi.new

		#check if product exists
		# if !PRODUCT_COST.has_key? params[:product_id]
		# 	render json: {:status => 400, :errors => [{"detail": "Product unavailable"}]  }
		# 	return
		# end

		amount = 100
		request_body = {
			:card_nonce => params[:nonce],
			:amount_money => {
				:amount => amount,
				:currency => 'USD'
			},
			:idempotency_key => SecureRandom.uuid
		}

		location = self.get_location

		begin
			transaction_response = transactions_api.charge(location.id, request_body)
		rescue SquareConnect::ApiError => e
            Rails.logger.error("Error encountered while charging card:: #{e.message}")
            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
			return
		end
		puts transaction_response

		# data = {
		# 	amount: amount,
		# 	user: {
		# 		name: params[:name],
		# 		street_address_1: params[:street_address_1],
		# 		street_address_2: params[:street_address_2],
		# 		state: params[:state],
		# 		zip: params[:zip],
		# 		city: params[:city]
		# 	},
		# 	card: resp.transaction.tenders[0].card_details.card
		# }

		# send receipt email to user
		# ReceiptMailer.charge_email(params[:email],data).deliver_now if Rails.env == "development"

		render json: {:status => 200, :resp => transaction_response}
    end

	def get_user(user_auth_token)
		# TODO: do Token model
		# exps and created fields
		@user ||= User.find(session[:user_id]) if session[:user_id] else User.where("auth_token = ? ", user_auth_token).first
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
