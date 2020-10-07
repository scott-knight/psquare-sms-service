# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageSubmitterService do
  let(:sms_message) { create(:sms_message) }
  let(:service) { MessageSubmitterService.new(sms_message_id: sms_message.id) }

  describe 'initialization' do
    it 'should have urls' do
    end

    it 'should have backup url' do
    end

    it 'should have primary url' do
    end

    it 'should have retry_on_fail' do
    end

    it 'should have sms_message' do
    end

    it 'should have total_tries' do
    end

    it 'should have json' do
    end

    it 'should log error if sms_message is not found' do
    end
  end

  describe 'instance method' do
    describe 'submit_message' do
      it 'should have done' do
      end

      it 'should call send_to_provider once if done on the first round' do
      end

      it 'should call send_to_provider twice if not done' do
      end

      it 'should call update_sms_message' do
      end
    end

    describe 'domain_and_path' do
      it 'should return the expected hash' do
      end
    end

    describe 'send_to_provider' do
      it 'it should have accurate retry count on fail' do
      end

      it 'it should have accurate retry count on success' do
      end
    end

    describe 'submit_to_api' do
      it 'should have accurate settings on fail' do
      end

      it 'should ahve accurate settings on success' do
      end
    end

    describe 'update_sms_message' do
      it 'should update the sms_message with success data' do
      end

      it 'should update the sms_message with failure data' do
      end
    end
  end
end