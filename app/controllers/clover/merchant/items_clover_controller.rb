
require "http"
require 'json'

class Clover::Merchant::ItemsCloverController < ApplicationController

    def initialize
        @clover_base_url         = Rails.application.secrets.clover_base_url
        @clover_base_api_url     = Rails.application.secrets.clover_base_api_url
    end

    # 1.all in one call
    def get_all_categories_with_items
        shop = get_shop(params[:id])

        remote_id       = shop.remote_id
        access_token    = shop.token

        begin
            puts "Getting categories for remote_id: #{remote_id}"
            cat_req = HTTP
            .headers(:authorization => "Bearer #{access_token}")
            .get("#{@clover_base_api_url}/v3/merchants/#{remote_id}/categories?expand=items.modifierGroups.modifiers,items.taxRates")
            cat_resp    = cat_req.parse
            categories  = cat_resp["elements"]
        rescue HTTP::ResponseError => e
            raise "Error on get_all_categories_with_items: #{e.message}"

            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
            return
        end

        render json: {:status => 200, :data => {data: categories, id: params[:id]}}
    end

    def get_all_with_modifies
        # binding.pry

        shop = get_shop(params[:id])

        remote_id       = shop.remote_id
        access_token    = shop.token

        begin
        	puts "Getting items for remote_id: #{remote_id}"
            items_req = HTTP
            .headers(:authorization => "Bearer #{access_token}")
            .get("#{@clover_base_api_url}/v3/merchants/#{remote_id}/items?expand=modifierGroups.modifiers")
            items_resp    = items_req.parse
            items  = items_resp["elements"]
        rescue HTTP::ResponseError => e
            raise "Error on get_items: #{e.message}"

            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
        	return
        end

        render json: {:status => 200, :data => {items: items}}
    end

    def get_with_modifiers
        # {{url}}/v3/merchants/{{mId}}?access_token={{token}}
        shop = get_shop(params[:id])

        item_id = params[:item_id]

        begin
        	puts "Getting item for remote_id: #{remote_id}"
            item_request = HTTP
            .headers(:authorization => "Bearer #{access_token}")
            .get("#{@clover_base_api_url}/v3/merchants/#{remote_id}/items/#{item_id}?expand=modifierGroups.modifiers")
            item_resp    = item_request.parse
            item  = item_resp["elements"]
        rescue HTTP::ResponseError => e
            raise "Error on get_item: #{e.message}"

            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
        	return
        end

        render json: {:status => 200, :data => {item: item}}
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
# create user
# add payment tool
# remove payment tool
# pay
