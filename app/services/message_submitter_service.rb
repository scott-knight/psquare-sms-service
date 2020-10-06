# frozen_string_literal: true

require 'faraday'

class MessageSubmitterService
  attr_reader :current_url, :done, :primary_url, :backup_url, :json, :response,
              :retry_on_fail, :sms_message, :tries, :total_tries, :urls

  def initialize(sms_message_id:, provider: 2, retry_on_fail: true)
    @urls = ProviderUrlService.new
    @backup_url = urls.provider_url(provider == 2 ? 1 : 2)
    @primary_url = urls.provider_url(provider)
    @retry_on_fail = retry_on_fail
    @sms_message = SmsMessage.find(sms_message_id)
    @total_tries = 0
    @json = Oj.to_json({
      to_number: sms_message.phone_number,
      message: sms_message.message,
      callback_url: urls.callback_url
    })
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "MessageSubmitterService was unable to find a record
      for SmsMessage.id: #{sms_message_id}. Error Message: #{e.to_s}".squish
  end

  def submit_message
    @done = false

    send_to_provider(primary_url, 'primary')
    send_to_provider(backup_url, 'backup') if retry_on_fail && !done
    update_sms_message
  end

  private

  def domain_and_path
    uri = URI(current_url)
    { url_domain: "#{uri.scheme}://#{uri.domain}", url_path: uri.path }
  end

  def send_to_provider(url, provider_type)
    @tries = 0

    until tries == 3 || done do
      submit_to_api(url)
      sleep 2 unless done
    end
  rescue => e
    Rails.logger.error "MessageSubmitterService encountered an error while
      submitting to the #{provider_type} external sms messaging endpoint, for
      url: #{url}, for sms_message.id: #{sms_message.id}.
      Error Message: #{e.to_s}. #{additional_message}".squish
    cycle_backup
  end

  def submit_to_api(url)
    @resposne = Faraday.post(url) do |req|
      req.headers['Content-Type'] = APP_JSON
      req.headers['Accept'] = APP_JSON
      req.headers['User-Agent'] = 'Faraday'
      req.body = json
    end

    @current_url = url
    @total_tries += 1
    @tries += 1
    @done = response.try(:code) == 200
  end

  def update_sms_message
    if done
      body = Oj.load(response.body, symbol_keys: true)
      @sms_message.update(
        { message_uuid: body[:message_id],
          status_code: response.status,
          total_tries: total_tries
        }.merge(domain_and_path(url))
      )
    else
      @sms_message.update(
        { status: 'System was unable to post to external sms services',
          status_code: response.try(:status) || 500,
          total_tries: total_tries
        }.merge(domain_and_path(url))
      )
    end
  end
end
