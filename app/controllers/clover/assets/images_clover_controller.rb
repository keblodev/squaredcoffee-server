
require "http"
require 'open-uri'
require 'json'

class Clover::Assets::ImagesCloverController < ApplicationController
    # return config

    def get_configs
        clover_aws_base     = Rails.application.secrets.clover_aws_base
        clover_aws_bucket   = Rails.application.secrets.clover_aws_bucket
        clover_aws_route    = Rails.application.secrets.clover_aws_route
        begin
            puts "Getting image config"
            img_config_req = HTTP.get("#{clover_aws_base}/#{clover_aws_bucket}/#{clover_aws_route}/config.json")
            img_config = img_config_req.parse
            app_config_req = HTTP.get("#{clover_aws_base}/#{clover_aws_bucket}/#{clover_aws_route}/appConfig.json")
            app_config = app_config_req.parse
        rescue HTTP::ResponseError => e
            raise "Error encountered while getting image config: #{e.message}"

            render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
            return
        end

        render json: {:status => 200, :data => {data: {
            assets_config:  img_config,
            app_config:     app_config
        }}}
    end

    def get

        file_id = params[:fileId]

        clover_aws_base     = Rails.application.secrets.clover_aws_base
        clover_aws_bucket   = Rails.application.secrets.clover_aws_bucket
        clover_aws_route    = Rails.application.secrets.clover_aws_route

        respond_to do |format|
            format.jpg do
                begin
                    puts "Getting image"
                    data = open(URI("#{clover_aws_base}/#{clover_aws_bucket}/#{clover_aws_route}/#{file_id}.jpg"))
                rescue Exception => e
                    raise "Error encountered while getting image config: #{e.message}"

                    render :json => {:error => JSON.parse(e.response_body)["errors"]}, :status => 400
                    return
                end

                send_data data.read, filename: "#{file_id}.jpg", type: data.content_type, disposition: 'inline',  stream: 'true', buffer_size: '4096'
            end
         end

    end

end
