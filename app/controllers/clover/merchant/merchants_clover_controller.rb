
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
        # {{url}}/v3/merchants/{{mId}}?access_token={{token}}
        shop = get_shop(params[:id])

        if shop
            render json: {:status => 200, :data => {shops: shop}}
        else
            render json: {:status => 404, :data => {ok: false}}
        end
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
