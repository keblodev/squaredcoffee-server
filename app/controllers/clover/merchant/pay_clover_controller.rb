require 'net/http'
require "http"
require 'openssl'
require 'json'
require 'base64'


class Clover::Merchant::PayCloverController < ApplicationController

    def pay
        ###############################################
        ########## BEGIN SCRIPT CONFIG SETUP ##########
        ###############################################

        clover_pay_api_url = Rails.application.secrets.clover_pay_api_url || "https://sandbox.dev.clover.com/v2/merchant/"

        # user = get_user(params[:auth]["token"]
        payConfig = params["payConfig"]

        order_id        = params["order_id"]

        shop            = get_shop(params[:merchant_id])
        shop_id         = shop.remote_id
        access_token    = shop.token

        merchant_id     = params[:merchant_id] # sandbox Test Merchant
        pay_api_url      = clover_pay_api_url #pay api is only here ..?
        amount          = [payConfig["total"].to_i, 50].max
        # tip_amount = 0
        # tax_amount = 0
        card_number     = payConfig["number"].to_s
        first6          = payConfig["number"].to_s.first(6)
        last4           = payConfig["number"].to_s.last(4)
        exp_month       = payConfig["expiry"].to_i/100
        exp_year        = ("20"+(payConfig["expiry"].to_i%100).to_s)
        cvv             = payConfig["cvc"]

        ###############################################
        ########## END SCRIPT CONFIG SETUP ############
        ###############################################

        # GET to /v2/merchant/{mId}/pay/key To get the encryption information needed for the pay endpoint.
        begin
            puts "Getting key for order #{order_id} for shop_id: #{shop_id}"
            key_order_request = HTTP
                .headers(
                    :authorization => "Bearer #{access_token}",
                )
                .get("#{pay_api_url}/#{merchant_id}/pay/key")
            key_response = key_order_request.parse
        rescue HTTP::ResponseError => e
            raise "Error on new order: #{e.message}"
            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
            return
        end

        modulus     = key_response["modulus"].to_i
        exponent    = key_response["exponent"].to_i
        prefix      = key_response["prefix"]

        # construct an RSA public key using the modulus and exponent provided by GET /v2/merchant/{mId}/pay/key
        rsa = OpenSSL::PKey::RSA.new.tap do |rsa|
            rsa.e = OpenSSL::BN.new(exponent)
            rsa.n = OpenSSL::BN.new(modulus)
        end

        # create a cipher from the RSA key and use it to encrypt the card number, prepended with the prefix from GET /v2/merchant/{mId}/pay/key
        encrypted = rsa.public_encrypt(prefix + card_number, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)

        # Base64 encode the resulting encrypted data into a string to Clover as the 'cardEncrypted' property.
        card_encrypted = Base64.encode64(encrypted)

        # POST to /v2/merchant/{mId}/pay
        post_data = {
            "orderId": order_id,
            # "tipAmount": tip_amount,
            # "taxAmount": tax_amount,
            "expMonth": exp_month,
            "cvv": cvv,
            "amount": amount,
            "currency": "usd",
            "last4": last4,
            "expYear": exp_year,
            "first6": first6,
            "cardEncrypted": card_encrypted
        }

        begin
            puts "Paying for order #{order_id} for shop_id: #{shop_id}"
            pay_order_request = HTTP
                .headers(
                    :authorization => "Bearer #{access_token}",
                    :content_type => "application/json",
                )
                .post(
                    "#{pay_api_url}/#{merchant_id}/pay",
                    :json => post_data
                )
            pay_resp = pay_order_request.parse
        rescue HTTP::ResponseError => e
            raise "Error on new order: #{e.message}"

            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
            return
        end

        if pay_resp["result"] == "APPROVED"
            render json: {:status => 200, :data => {resp: pay_resp}}
        else
            render :json => {:message => "payment failed"}, :status => 400
        end
    end

	def get_user(user_auth_token)
		User.find_by_auth_token(user_auth_token) or not_found
	end

    def get_shop(remote_id)
        Shop.find_by_remote_id(remote_id) or not_found
    end

    def not_found
        raise ActionController::RoutingError.new('Not Found')
    end
end