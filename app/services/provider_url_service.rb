# frozen_string_literal: true

class ProviderUrlService

  AMAZON_URL = 'https://jo3kcwlvke.execute-api.us-west-2.amazonaws.com/dev'

  attr_reader :callback_url, :endpoint, :provider1_url, :provider2_url,
              :public_url, :host

  def initialize(endpoint: 'delivery_status')
    @provider1_url = "#{AMAZON_URL}/provider1"
    @provider2_url = "#{AMAZON_URL}/provider2"
    @endpoint = endpoint
    call_setup
  end

  def call_ngrok
    return nil unless Rails.env.development?

    ngrok_uri  = URI('http://127.0.0.1:4040/api/tunnels')
    ngork_resp = Net::HTTP.get(ngrok_uri)
    Oj.load(ngork_resp, symbol_keys: true).dig(:tunnels, 0, :public_url)
  end

  def call_setup
    set_public_url
    set_callback_url
    true
  end

  def provider_url(provider)
    provider == 1 ? provider1_url : provider2_url
  end

  def set_callback_url
    uri = URI(public_url)
    @host = uri.host
    @callback_url = "#{public_url}/#{API_VERSION}/sms_messages/#{endpoint}"
  end

  def set_public_url
    @public_url =
      if Rails.env.development?
        call_ngrok
      else
        "https://#{Rails.application.routes.default_url_options[:host]}"
      end
  end
end