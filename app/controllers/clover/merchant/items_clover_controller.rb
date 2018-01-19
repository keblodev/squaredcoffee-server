
require "http"
require 'json'

class Clover::Merchant::ItemsCloverController < ApplicationController

    def initialize
        @clover_base_url         = Rails.application.secrets.clover_base_url
        @clover_base_api_url     = Rails.application.secrets.clover_base_api_url
    end

    # 1.all in one call
    def get_all_categories_with_items
        if shop = get_shop(params[:id])
            remote_id       = shop.remote_id
            access_token    = shop.token

            if is_rmote_shop_authorized(remote_id, access_token)
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
            else
                render :json => {:message => "shop not authorized", reset_app_state: true}, :status => 409
            end

        else
            render :json => {:message => "shop not found", reset_app_state: true}, :status => 404
        end
    end

    def get_all_with_modifies

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

    def get_shop(remote_id)
        Shop.find_by_remote_id(remote_id)
    end

    def is_rmote_shop_authorized(shop_id, access_token)
        is_rmote_shop_authorized = true
        begin
            puts "Getting info for shop_id: #{shop_id}"
            merchant_request = HTTP
            .headers(:authorization => "Bearer #{access_token}")
            .get("#{@clover_base_api_url}/v3/merchants/#{shop_id}?expand=address,openingHours")
            merchant_resp = merchant_request.parse
            if merchant_request.status == 401
                if rejected_shop = Shop.find_by_remote_id(shop_id)
                    is_rmote_shop_authorized = false
                    Shop.delete(rejected_shop.id)
                end
            end

        rescue HTTP::ResponseError => e
            raise "Error encountered while getting access token: #{e.message}"

            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
            is_rmote_shop_authorized = false
            is_rmote_shop_authorized
        end

        is_rmote_shop_authorized
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
