# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmsMessage, type: :model do
  describe 'before_validation' do
    context 'sanitize_phone_number' do
      it 'should remove whitespace' do
        sm = build(:sms_message, phone_number: ' 9137804063  ')
        sm.save

        expect(sm.phone_number.length).to eql(10)
        expect(sm.phone_number[0]).to eql('9')
        expect(sm.phone_number[9]).to eql('3')
      end

      it 'should only keep numbers' do
        sm = build(:sms_message, phone_number: '+1 (913) 780-4063')
        sm.save

        expect(sm.phone_number.delete('0-9').length).to eql(0)
      end

      it "should remove the first char if it's `1` and the length > 10" do
        sm = build(:sms_message, phone_number: '+1 (913) 780-4063')
        sm.save

        expect(sm.phone_number[0]).to eql('9')
      end
    end
  end

  describe 'validation' do
    context 'phone_number' do
      it 'should NOT be blank' do
        sm = build(:sms_message, phone_number: '')
        sm.save
        errors = sm.errors.full_messages

        expect(errors).to include("Phone number can't be blank")
      end

      it 'should have the minimum 10 characters' do
        sm = build(:sms_message, phone_number: '1234567')
        sm.save
        errors = sm.errors.full_messages

        expect(errors).to include("Phone number is too short (minimum is 10 characters)")
      end

      it 'should have the maximum 10 characters' do
        sm = build(:sms_message, phone_number: '12345678901234')
        sm.save
        errors = sm.errors.full_messages

        expect(errors).to include("Phone number is too long (maximum is 10 characters)")
      end

      it 'should error with a 911 prefix' do
        sm = build(:sms_message, phone_number: '9113204567')
        sm.save
        errors = sm.errors.full_messages

        expect(errors).to include("Phone number can't start with 911")
      end

      it 'should error with a 411 prefix' do
        sm = build(:sms_message, phone_number: '4113204567')
        sm.save
        errors = sm.errors.full_messages

        expect(errors).to include("Phone number can't start with 411")
      end
    end

    context 'message' do
      it 'should be present' do
        sm = build(:sms_message, message_txt: '', phone_number: '9134567890')
        sm.save
        errors = sm.errors.full_messages

        expect(errors).to include("Message txt can't be blank")
      end
    end
  end

  describe 'scope' do
    describe 'discarded' do
      it 'should return ONLY discarded records' do
        2.times { create(:sms_message, :successful_submit, :discarded, phone_number: '9134567890') }
        create(:sms_message)

        expect(SmsMessage.discarded.size).to eq 2
      end
    end

    describe 'kept' do
      it 'should return ONLY kept records' do
        2.times { create(:sms_message, :successful_submit, :discarded, phone_number: '9134567890') }
        3.times { create(:sms_message, :successful_submit, phone_number: '9134567890') }

        expect(SmsMessage.kept.size).to eq 3
      end
    end

    describe 'failed_submit' do
      it 'should return expected records' do
        3.times { create(:sms_message, :failed_submit, phone_number: '9134567890') }
        create(:sms_message, :successful_submit, phone_number: '9134567890')

        expect(SmsMessage.failed_submit.size).to eq 3
      end
    end

    describe 'search_message' do
      it 'should return expected records' do
        3.times { create(:sms_message, :successful_submit, phone_number: '9134567890') }
        2.times { create(:sms_message, :successful_submit, message_txt: 'Sponge Bob Lives!', phone_number: '9134567890') }
        create(:sms_message, :failed_submit, message_txt: 'Failed Test Message', phone_number: '9134567890' )
        create(:sms_message, :failed_submit, message_txt: 'What about bob?', phone_number: '9134567890' )

        expect(SmsMessage.search_message_txt('test').size).to eq 4
        expect(SmsMessage.search_message_txt('bob').size).to eq 3
      end
    end

    describe 'search_message_uuid' do
      it 'should return expected records' do
        uuid = SecureRandom.uuid
        3.times { create(:sms_message, :successful_submit, phone_number: '9134567890') }
        create(:sms_message, :successful_submit, message_uuid: uuid, phone_number: '9134567890')

        expect(SmsMessage.search_message_uuid(uuid.last(17)).size).to eq 1
      end
    end

    describe 'search_phone' do
      it 'should return expected records' do
        create(:sms_message, :successful_submit, phone_number: '913 345 6789')
        create(:sms_message, :successful_submit, phone_number: '913 123 6789')
        create(:sms_message, :successful_submit, phone_number: '913 345 1234')

        expect(SmsMessage.search_phone('913').size).to eq 3
        expect(SmsMessage.search_phone('123').size).to eq 2
        expect(SmsMessage.search_phone('6789').size).to eq 2
      end
    end

    describe 'search_status' do
      it 'should return expected records' do
        2.times { create(:sms_message, :successful_submit, phone_number: '9134567890') }
        create(:sms_message, :failed_submit, phone_number: '9134567890')
        create(:sms_message, :successful_submit, status: 'It worked well', phone_number: '9134567890')

        expect(SmsMessage.search_status('Lorem ipsum').size).to be 2
        expect(SmsMessage.search_status('fail').size).to eq 1
        expect(SmsMessage.search_status('worked').size).to eq 1
      end
    end

    describe 'search_url_domain' do
      it 'should return expected records' do
        2.times { create(:sms_message, :successful_submit, url_domain: 'https://success-test.com', phone_number: '9134567890') }
        create(:sms_message, :failed_submit, url_domain: 'https://failed-test.com')

        expect(SmsMessage.search_url_domain('success').size).to eq 2
        expect(SmsMessage.search_url_domain('fail').size).to eq 1
        expect(SmsMessage.search_url_domain('test').size).to eq 3
      end
    end

    describe 'search_url_path' do
      it 'should return expected records' do
        2.times { create(:sms_message, :successful_submit, url_path: '/success/test2.com', phone_number: '9134567890') }
        create(:sms_message, :failed_submit, url_path: '/failed/test1')

        expect(SmsMessage.search_url_path('success').size).to eq 2
        expect(SmsMessage.search_url_path('fail').size).to eq 1
        expect(SmsMessage.search_url_path('test').size).to eq 3
      end
    end

    describe 'unsubmitted' do
      it 'should return expected records' do
        2.times { create(:sms_message, :successful_submit, phone_number: '9134567890') }
        3.times { create(:sms_message, :failed_submit, phone_number: '9134567890') }
        2.times { create(:sms_message, phone_number: '9134567890') }

        expect(SmsMessage.unsubmitted.size).to eq 2
      end
    end
  end

  describe 'instance methods' do
    describe 'submitted?' do
      it 'should return true' do
        sm = build(:sms_message, :successful_submit, phone_number: '9134567890')

        expect(sm.submitted?).to be_truthy
      end

      it 'should return false' do
        sm = build(:sms_message, phone_number: '9134567890')

        expect(sm.submitted?).to be_falsey
      end
    end

    describe 'submitted_url' do
      it 'should return a full url' do
        parts = ['http://good.com', '/success/test2.com']
        sm = build(:sms_message, :successful_submit, url_domain: parts[0], url_path: parts[1])

        expect(sm.submitted_url).to eq parts.join
      end
    end
  end
end
