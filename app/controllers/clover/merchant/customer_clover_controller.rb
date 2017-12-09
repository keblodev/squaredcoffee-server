
require "http"
require 'json'

class Clover::Merchant::CustomerCloverController < ApplicationController
# get merchants


    def initialize
        @clover_base_url         = Rails.application.secrets.clover_base_url
        @clover_base_api_url     = Rails.application.secrets.clover_base_api_url
    end

    def get_all_with_modifiers

        shop = get_shop(params[:id])

        remote_id       = shop.remote_id
        access_token    = shop.token

        begin
        	puts "Getting categories for remote_id: #{remote_id}"
            cat_request = HTTP
            .headers(:authorization => "Bearer #{access_token}")
            .get("#{@clover_base_api_url}/v3/merchants/#{remote_id}/items?expand=modifierGroups")
            cat_resp    = cat_request.parse
            categories  = cat_resp["elements"]
        rescue HTTP::ResponseError => e
            raise "Error on get_categories: #{e.message}"

            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
        	return
        end

        render json: {:status => 200, :data => {shops: shops}}
    end

    def get
        # {{url}}/v3/merchants/{{mId}}?access_token={{token}}
        shop = get_shop(params[:id])

        item_id = params[:item_id]

        if shop
            render json: {:status => 200, :data => {shops: shop}}
        end
    end

    def get_categories_with_items

        shop = get_shop(params[:id])

        remote_id         = shop.remote_id
        access_token    = shop.token

        begin
        	puts "Getting categories for remote_id: #{remote_id}"
            cat_request = HTTP
            .headers(:authorization => "Bearer #{access_token}")
            .get("#{@clover_base_api_url}/v3/merchants/#{remote_id}/categories?expand=items")
            cat_resp    = cat_request.parse
            categories  = cat_resp["elements"]
        rescue HTTP::ResponseError => e
            raise "Error on get_categories: #{e.message}"

            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
        	return
        end

        render json: {:status => 200, :data => {categories: categories}}
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
