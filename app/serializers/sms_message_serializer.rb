class SmsMessageSerializer
  include JSONAPI::Serializer
  SMS_MESSAGES_PATH = "/#{API_VERSION}/sms_messages"

  attributes :phone_number, :message, :message_id, :status, :status_code,
             :created_at, :updated_at, :discarded_at

  link :self do |object|
    { url: "#{SMS_MESSAGES_PATH}/#{object.id}" }
  end
end
