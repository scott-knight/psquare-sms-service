# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmsMessage, type: :model do
  describe 'before_validations' do
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

  describe 'validations' do
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
        sm = build(:sms_message, message: '')
        sm.save
        errors = sm.errors.full_messages

        expect(errors).to include("Message can't be blank")
      end
    end
  end

  describe 'scopes' do
  end
end
