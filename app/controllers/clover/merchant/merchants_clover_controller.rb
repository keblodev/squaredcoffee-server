
require "http"
require 'json'

class Clover::Merchant::MerchantsCloverController < ApplicationController

    def initialize
        @clover_base_url         = Rails.application.secrets.clover_base_url
        @clover_base_api_url     = Rails.application.secrets.clover_base_api_url
    end

    def getAll
        shops = Shop.all
        # TODO: check with allowed stores config(?)
        render json: {:status => 200, :data => {shops: shops}}
    end

    def get
        shop = get_shop(params[:id])

        if shop
            render json: {:status => 200, :data => {shops: shop}}
        else
            render json: {:status => 404, :data => {ok: false}}
        end
    end

    def refetchAll

        shops = Shop.all

        clover_vendor_id            = Rails.application.secrets.clover_vendor_id

        updated_shops = shops.map do |shop|
                shop_id         = shop[:remote_id]
                access_token    = shop[:token]
                begin
                    puts "Getting info for shop_id: #{shop_id}"
                    merchant_request = HTTP
                    .headers(:authorization => "Bearer #{access_token}")
                    .get("#{@clover_base_api_url}/v3/merchants/#{shop_id}?expand=address,openingHours")
                    merchant_resp = merchant_request.parse
                    name            = merchant_resp["name"]
                    address         = merchant_resp["address"]
                    opening_hours   = merchant_resp["opening_hours"]

                rescue HTTP::ResponseError => e
                    binding.pry
                    raise "Error encountered while getting access token: #{e.message}"

                    render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
                    return
                end

                shop = Shop.find_or_create_by(
                    remote_id: shop_id
                )

                shop.vendor_id      = clover_vendor_id
                shop.name           = name
                shop.address        = address.to_json
                shop.desc           = address["address3"] || ''
                shop.opening_hours  = opening_hours['elements'].first.to_json
                shop.token          = access_token

                unless shop.save
                    render :json => {:error => '[clover|authorize]: too bad'}, :status => 500
                else
                    shop
                end
            end

            render json: {:status => 200, :data => {shops: updated_shops}}
    end

    def get_shop(remote_id)
        Shop.find_by_remote_id(remote_id) or not_found
    end

    def not_found
        raise ActionController::RoutingError.new('Not Found')
    end

end
# get categories
# get merchant
# get oppening hours
# get devices
# get items
# get modifiers
# creat and order
# update order
# cancell order/refund
