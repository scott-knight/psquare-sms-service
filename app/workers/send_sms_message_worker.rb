# frozen_string_literal: true

class SendSmsMessageWorker
  include Sidekiq::Worker
  sidekiq_options(retry: false)

  def perform(sms_message_id, provider: nil, retry_on_fail: true, weight1: 30, weight2: 70)
    MessageSubmitterService.new(
      sms_message_id: sms_message_id,
      provider:       provider,
      retry_on_fail:  retry_on_fail,
      weight1:        weight1,
      weight2:        weight2
    ).call
  end
end