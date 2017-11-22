require 'aws-sdk-ses'

class AwsMailer

    def self.make_email_sub_payload(data, charset = nil)
        default_charset = 'UTF-8'
        return {
            data: data,
            charset: charset || default_charset,
        }
    end

    def self.make_email_payload(params)
        body = {}
        to_addresses = params[:receiver].is_a?(Array) ? params[:receiver] : [params[:receiver]]

        if params[:body_html] != nil
            body[:html] = make_email_sub_payload(params[:body_html])
        end
        if params[:body_text]
            body[:text] = make_email_sub_payload(params[:body_text].html_safe)
        end
        return {
            destination: {
                to_addresses: Rails.application.secrets["emails"]["master_override"] && [Rails.application.secrets["emails"]["master_override"]] || to_addresses,
            },
            message: {
                body:       body,
                subject:    make_email_sub_payload(params[:subject]),
            },
            source: params[:sender] || Rails.application.secrets["aws"]["ses"]["sender"],
        }
    end

    def self.send_email(params)
        ses = Aws::SES::Client.new({
            region: Rails.application.secrets["aws"]["ses"]["region"],
        })
        payload = make_email_payload(params)
        res = ses.send_email(payload)
    end
end
