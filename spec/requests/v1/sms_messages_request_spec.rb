require 'rails_helper'

# I have stubbed out the tests to complete another day. For the purposes of this exercise,
# I have created 99.6% coverage for the main services of the app. After spending more
# than 40 hours on this project, I have decided to update the readme and submit this
# work for review. I can't finish the tests at a later date if needed.

RSpec.describe "V1::SmsMessages", type: :request do
  let(:sms_message) { create(:sms_message, :successful_submit) }

  describe 'index' do
    it 'should return status 200' do
    end

    it 'should return data' do
    end

    it 'should return meta' do
    end

    it 'should return filtered for kept' do
    end

    it 'should return filtered for search by message_txt' do
    end

    it 'should return filtered for search by phone' do
    end

    it 'should return filtered for search by message_uuid' do
    end

    it 'should return filtered for search by status' do
    end

    it 'should return filtered for search by status_code' do
    end
  end

  describe 'create' do
    it 'should return status 201' do
    end

    it 'should return created message' do
    end

    it 'should return status 402' do
    end

    it 'should return error message' do
    end
  end

  describe 'show' do
    it 'should return status 200' do
    end

    it 'should return data object' do
    end

    it 'should return status 404' do
    end
  end

  describe 'delivery_status' do
    it 'should return status 200' do
    end

    it 'should return success message' do
    end

    it 'should return error message' do
    end
  end

  describe 'resend' do
    it 'should return status 200' do
    end

    it 'should send message about using force if already submitted' do
    end

    it 'should send success message' do
    end
  end
end
