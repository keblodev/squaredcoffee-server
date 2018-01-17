require "http"
require 'json'

class Clover::Auth::AuthCloverController < ApplicationController

    def authorize
        code        = params[:code];
        shop_id     = params[:merchant_id];
        client_id   = params[:client_id];

        clover_application_secret   = Rails.application.secrets.clover_application_secret
        clover_application_id       = Rails.application.secrets.clover_application_id
        clover_base_url             = Rails.application.secrets.clover_base_url
        clover_base_api_url         = Rails.application.secrets.clover_base_api_url
        clover_vendor_id            = Rails.application.secrets.clover_vendor_id

        begin
            puts "Getting auth token for shop_id: #{shop_id}"
            request = HTTP.get("#{clover_base_api_url}/oauth/token?client_id=#{clover_application_id}&client_secret=#{clover_application_secret}&code=#{code}")
            resp = request.parse
            access_token = resp["access_token"]
        rescue HTTP::ResponseError => e
            raise "Error encountered while getting access token: #{e.message}"

            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
            return
        end

        begin
        	puts "Getting auth token for shop_id: #{shop_id}"
            merchant_request = HTTP
            .headers(:authorization => "Bearer #{access_token}")
            .get("#{clover_base_api_url}/v3/merchants/#{shop_id}?expand=address,openingHours")
            merchant_resp = merchant_request.parse

            name            = merchant_resp["name"]
            address         = merchant_resp["address"]
            opening_hours   = merchant_resp["opening_hours"]

        rescue HTTP::ResponseError => e
            raise "Error encountered while getting access token: #{e.message}"

            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
        	return
        end

        shop = Shop.find_or_create_by(
            remote_id: params[:merchant_id]
        )

        shop.vendor_id      = clover_vendor_id
        shop.name           = name
        shop.address        = address.to_json
        shop.desc           = address["address3"] || ''
        shop.opening_hours  = opening_hours['elements'].first.to_json
        shop.token          = access_token

        if shop.save
            render :file => "#{Rails.root}/public/200.html",  :status => 200
        else
            render :json => {:error => '[clover|authorize]: too bad'}, :status => 500
        end
    end
end
