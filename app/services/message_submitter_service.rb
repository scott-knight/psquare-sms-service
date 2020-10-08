# frozen_string_literal: true

require 'faraday'

class MessageSubmitterService
  CACHE_NAME = 'provider'

  attr_reader :backup, :backup_url, :current_url, :done, :json_payload, :lbc,
              :primary, :primary_url, :provider,  :response, :retry_on_fail,
              :sms_message, :tries, :total_tries, :urls, :weight1, :weight2,
              :delay

  def initialize(sms_message_id, provider: nil, retry_on_fail: true, weight1: 30, weight2: 70, delay: 2)
    @urls = ProviderUrlService.new
    @retry_on_fail = retry_on_fail
    @provider = provider
    @sms_message = SmsMessage.find(sms_message_id)
    @weight1 = weight1
    @weight2 = weight2
    @delay = delay
    set_json_payload
    set_primary_and_backup
    set_primary_and_backup_urls
  end

  def call
    submit_message
    self
  end

  private

  def domain_and_path
    uri = URI(current_url)
    { url_domain: "#{uri.scheme}://#{uri.host}", url_path: uri.path }
  end

  def provider_valid?
    provider.present? && [1, 2].include?(provider)
  end

  def set_primary_and_backup_from_provider_variable
    @primary = provider
    @backup  = primary == 1 ? 2 : 1
    @lbc = LoadBalanceCalcService.new(
      CACHE_NAME,
      weight1: @primary == 1 ? 1 : 0,
      weight2: @primary == 2 ? 1 : 0
    ).call
  end

  def set_primary_and_backup
    return set_primary_and_backup_from_provider_variable if provider_valid?

    @lbc = LoadBalanceCalcService.new(
      CACHE_NAME,
      weight1: weight1,
      weight2: weight2
    ).call
    @primary = lbc.primary
    @backup = lbc.backup
    @provider = @primary unless provider_valid?
  end

  def set_primary_and_backup_urls
    @primary_url = urls.provider_url(primary)
    @backup_url = urls.provider_url(backup)
  end

  def set_json_payload
    @json_payload = Oj.to_json({
      to_number: sms_message.phone_number,
      message: sms_message.message_txt,
      callback_url: urls.callback_url
    })
  end

  def send_to_provider(url)
    @tries = 0
    @current_url = url

    until tries == 3 || done do
      submit_to_api(url)
      sleep delay unless done
    end
  end

  def submit_to_api(url)
    @response = Faraday.post(url) do |req|
      req.headers['Content-Type'] = APP_JSON
      req.headers['User-Agent'] = 'Faraday'
      req.body = json_payload
    end

    @total_tries += 1
    @tries += 1
    @done = response.try(:status) == 200
  end

  def submit_message
    @done = false
    @total_tries = 0
    REDIS.incr(lbc.cache_name_to_increment)

    send_to_provider(primary_url)
    send_to_provider(backup_url) if retry_on_fail && !done
    update_sms_message
  end

  def sms_message_data
    if done
      body = Oj.load(response.body, symbol_keys: true)
      { message_uuid: body[:message_id] }
    else
      { status: 'System failed to post to external sms services' }
    end
  end

  def update_sms_message
    @sms_message.update(
      sms_message_data.merge(total_tries: total_tries).merge(domain_and_path)
    )
  end
end
