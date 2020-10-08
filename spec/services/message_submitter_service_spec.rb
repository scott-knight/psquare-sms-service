# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageSubmitterService do
  let(:sms_message) { create(:sms_message, phone_number: '9134567890') }
  let(:service) { MessageSubmitterService.new(sms_message_id: sms_message.id) }

  after(:each) do
    REDIS.set('provider1_count', 0)
    REDIS.set('provider2_count', 0)
  end

  describe 'instance method' do
    describe 'update_sms_message' do
      it 'should update the sms_message with success data' do
        sms = create(:sms_message, phone_number: '9134567890')
        stub_submit_sms_service_failure(provider: 1, to_number: sms.phone_number)
        stub_submit_sms_service_failure(provider: 2, to_number: sms.phone_number)
        mss = MessageSubmitterService.new(sms.id, delay: 0).call
      end

      it 'should update the sms_message with failure data' do
        sms = create(:sms_message, phone_number: '9134567890')
        stub_submit_sms_service_failure(provider: 1, to_number: sms.phone_number)
        stub_submit_sms_service_failure(provider: 2, to_number: sms.phone_number)
        mss = MessageSubmitterService.new(sms.id, delay: 0).call
      end
    end
  end

  describe 'if given provider' do
    it 'should set the provier 1 form variable' do
      sms = create(:sms_message, phone_number: '9134567890')
      mss = MessageSubmitterService.new(sms.id, delay: 0, provider: 1)

      expect(mss.provider).to eql 1
      expect(mss.lbc.cache_name_to_increment).to eql 'provider1_count'
    end

    it 'should set the provier 2 form variable' do
      sms = create(:sms_message, phone_number: '9134567890')
      mss = MessageSubmitterService.new(sms.id, delay: 0, provider: 2)

      expect(mss.provider).to eql 2
      expect(mss.lbc.cache_name_to_increment).to eql 'provider2_count'
    end

    it 'should set the provider from calculation if invalid' do
      sms = create(:sms_message, phone_number: '9134567890')
      mss = MessageSubmitterService.new(sms.id, delay: 0, provider: 3)

      expect(mss.provider).to eql 2
      expect(mss.lbc.cache_name_to_increment).to eql 'provider2_count'
    end
  end

  describe 'if retry_on_fail is false' do
    it 'should have a retry count of greater than 1' do
      sms = create(:sms_message, phone_number: '9134567890')
      stub_submit_sms_service_failure(provider: 1, to_number: sms.phone_number)
      stub_submit_sms_service_failure(provider: 2, to_number: sms.phone_number)
      mss = MessageSubmitterService.new(sms.id, delay: 0).call

      expect(mss.total_tries).to eql(6)
    end
  end

  describe 'ratios' do
    describe 'after submitting' do
      it 'should have the expected 30 / 70 split' do
        20.times { create(:sms_message, phone_number: '9134567890') }

        SmsMessage.unsubmitted.each do |sms|
          stub_submit_sms_service_success(provider: 1, to_number: sms.phone_number)
          stub_submit_sms_service_success(provider: 2, to_number: sms.phone_number)
          MessageSubmitterService.new(sms.id).call
        end

       ratio = (REDIS.get('provider1_count').to_i.fdiv REDIS.get('provider2_count').to_i).round(2)
       expect(ratio).to be_within(0.03).of(0.43)
      end
    end


    it 'should have the expected 20 / 80 split' do
      20.times { create(:sms_message, phone_number: '9134567890') }

      SmsMessage.unsubmitted.each do |sms|
        stub_submit_sms_service_success(provider: 1, to_number: sms.phone_number)
        stub_submit_sms_service_success(provider: 2, to_number: sms.phone_number)
        MessageSubmitterService.new(sms.id, weight1: 20, weight2: 80).call
      end

     ratio = (REDIS.get('provider1_count').to_i.fdiv REDIS.get('provider2_count').to_i).round(2)
     expect(ratio).to be_within(0.03).of(0.25)
    end
  end
end