# frozen_string_literal: true

=begin
  A service which load balances external api calls to an SMS deleivery service.
  The default load blanace is 3/7 or 0.43. The formula used to calculate
  the 3/7 load balance produces and average load balance between 0.43 and 0.45.

  Arguments:
  * :sms_message_id
    The ID of the SmsMessage object that you want to send.

  * :provider
      Use 1 or 2. This forces the service to send to a specific provider
      (currently there are only 2). If you send anything other than 1 or 2,
      it will pick a provider based on the 3/7 ratio.

  * :retry_on_fail
      The default is `true`. This will cause the message submitter service
      to call (rollover to) a backup provider if the primary provider fails
      to respond succesfully. If you dont want it to send to the backup, set
      the value to `false`.

  * :weight1 & :weight2
      Allows you to set the weighted ratio.
      Side note: I didn't try to break this. I could have hard-coded the
      values but I thought it would be much nicer if a user had the option
      to set the needed values for the job. You can mess with it as you will.


  REDIS needs to be running in the background for this worker to work.

  * validate_redis_cache
    if you can't tell from the code, the app needed a way to keep track of
    the overall load balance. This checks to see if the balance variables
    exist, creates them if they don't, and resets the variables to 0 after 9999
    messages have been sent by the second provider.
=end

require 'faraday'

class MessageSubmitterService
  attr_reader :current_url, :done, :primary_url, :backup_url, :provider,
              :provider1_count, :provider2_count, :json_payload, :response,
              :retry_on_fail, :send_to_provider1, :sms_message, :tries,
              :total_tries, :urls, :weighted_ratio

  def initialize(sms_message_id:, provider: nil, retry_on_fail: true, weight1: 30, weight2: 70)
    @urls           = ProviderUrlService.new
    @retry_on_fail  = retry_on_fail
    @provider       = provide
    @sms_message    = SmsMessage.find(sms_message_id)
    @weighted_ratio = weight1.fdiv weight2
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "MessageSubmitterService was unable to find a record
      for SmsMessage.id: #{sms_message_id}. Error Message: #{e.to_s}".squish
  end

  def call
    validate_redis_cache
    set_the_provider_counts
    set_the_json_payload

    determine_the_primary_provider
    set_the_primary_and_backup_urls
    submit_message
  end

  def determine_provider_from_variable
    @send_to_provider1 = provider == 1
  end

  def determine_the_primary_provider
    return determine_provider_from_variable if provider_valid?

    if provider1_count + provider2_count == 0
      if weighted_ratio <= 1.0
        REDIS.incr('provider2_count')
        @send_to_provider1 = false
      else
        REDIS.incr('provider1_count')
        @send_to_provider1 = true
      end
    else
      r1 = provider1_count.succ.fdiv provider2_count
      r2 = provider1_count.fdiv provider2_count.succ

      if (r1 - weighted_ratio).abs <= (r2 - weighted_ratio).abs
        REDIS.incr('provider1_count')
        @send_to_provider1 = true
      else
        REDIS.incr('provider2_count')
        @send_to_provider1 = false
      end
    end
  end

  def domain_and_path
    uri = URI(current_url)
    { url_domain: "#{uri.scheme}://#{uri.host}", url_path: uri.path }
  end

  def set_the_provider_counts
    @provider1_count = REDIS.get('provider1_count').to_i
    @provider2_count = REDIS.get('provider2_count').to_i
  end

  def set_the_primary_and_backup_urls
    @primary_url = urls.provider_url(send_to_provider1 ? 1 : 2)
    @backup_url  = urls.provider_url(primary_url.match?(/provider1/) ? 2 : 1 )
  end

  def set_the_json_payload
    @json_payload = Oj.to_json({
      to_number:    sms_message.phone_number,
      message:      sms_message.message,
      callback_url: urls.callback_url
    })
  end

  def provider_valid?
    provider.present? && [1, 2].include?(provider)
  end

  def send_to_provider(url)
    @tries = 0
    @current_url = url

    until tries == 3 || done do
      submit_to_api(url)
      sleep 2 unless done
    end
  end

  def submit_to_api(url)
    @resposne = Faraday.post(url) do |req|
      req.headers['Content-Type'] = APP_JSON
      req.headers['User-Agent'] = 'Faraday'
      req.body = json_payload
    end

    @total_tries += 1
    @tries += 1
    @done = response.try(:code) == 200
  end

  def submit_message
    @done = false
    @total_tries = 0

    send_to_provider(primary_url)
    send_to_provider(backup_url) if retry_on_fail && !done
    update_sms_message
  end

  def sms_message_data
    if done
      body = Oj.load(response.body, symbol_keys: true)
      { message_uuid: body[:message_id],
        status_code: response.status }
    else
      { status: 'System was unable to post to external sms services',
        status_code: response.try(:status) || 500 }
    end
  end

  def update_sms_message
    @sms_message.update(
      sms_message_data.merge(total_tries: total_tries).merge(domain_and_path(current_url))
    )
  end

  def validate_redis_cache
    count = REDIS.get('provider2_count')

    if count.blank? || count.to_i > 9999
      REDIS.set('provider1_count', 0)
      REDIS.set('provider2_count', 0)
    end
  end
end
