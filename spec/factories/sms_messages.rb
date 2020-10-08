# frozen_string_literal: true
# :nocov:

FactoryBot.define do
  factory :sms_message do
    phone_number { Faker::PhoneNumber.cell_phone }
    message_txt { 'This is a test message. Enjoy!' }

    trait :successful_submit do
      after :build do |sms_message|
        sms_message.message_uuid = sms_message.message_uuid || SecureRandom.uuid
        sms_message.status       = sms_message.status || 'Lorem ipsum dolor sit amet'
        sms_message.total_tries  = sms_message.total_tries || rand(1..6)
        sms_message.url_domain   = sms_message.url_domain || 'https://my-amazing-test-domain.com'
        sms_message.url_path     = sms_message.url_path || "/test/provider#{rand(1..2)}"
      end
    end

    trait :failed_submit do
      after :build do |sms_message|
        sms_message.message_uuid = sms_message.message_uuid || SecureRandom.uuid
        sms_message.status      = sms_message.status || 'System failed to post to external sms services'
        sms_message.total_tries = sms_message.total_tries || rand(3..6)
        sms_message.url_domain  = sms_message.url_domain || 'https://my-amazing-test-domain.com'
        sms_message.url_path    = sms_message.url_path || "/test/provider#{rand(1..2)}"
      end
    end

    trait :discarded do
      after :build do |sms_message|
        sms_message.discarded_at = sms_message.discarded_at || Time.current - (rand(2..10)).days
      end
    end
  end
end
# :nocov:
