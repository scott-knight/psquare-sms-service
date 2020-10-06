# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageSubmitterService do
  let(:sms_message) { create(:sms_message) }
  let(:service) { MessageSubmitterService.new(sms_message_id: sms_message.id) }

  describe 'initialization' do
  end

  describe 'instance method' do
  end
end