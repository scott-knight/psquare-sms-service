# frozen_string_literal: true
# :nocov:

FactoryBot.define do
  factory :sms_message do
    phone_number { Faker::PhoneNumber.cell_phone }
    message { 'This is a test message. Enjoy!' }

    trait :with_provider1 do
      after :build do |sms_message|
        sms_message.message_id = SecureRandom.uuid
        sms_message.retrys = rand(0..3)
        sms_message.sent_to_provider1 = true
        sms_message.sent_to_provider2 = false
        sms_message.status = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
        sms_message.status_code = 200
        sms_message.successful_provider = 1

      end
    end

    trait :with_provider2 do
      after :build do |sms_message|
        sms_message.message_id = SecureRandom.uuid
        sms_message.retrys = rand(0..3)
        sms_message.sent_to_provider1 = false
        sms_message.sent_to_provider2 = true
        sms_message.status = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
        sms_message.status_code = 200
        sms_message.successful_provider = 2

      end
    end

    trait :with_both_providers do
      after :build do |sms_message|
        sms_message.message_id = SecureRandom.uuid
        sms_message.retrys = rand(2..6)
        sms_message.sent_to_provider1 = true
        sms_message.sent_to_provider2 = true
        sms_message.status = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
        sms_message.status_code = 200
        sms_message.successful_provider = rand > 0.5 ? 1 : 2
      end
    end
  end
end
# :nocov:
