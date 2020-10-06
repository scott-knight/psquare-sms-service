
require 'rails_helper'

RSpec.describe SendSmsMessageWorker, type: :worker do
  let(:sms_message) { create(:sms_message) }

  before(:each) do
    Sidekiq::Worker.clear_all
  end

  describe 'perform' do
    it 'should work' do
      SendSmsMessageWorker.perform_async(sms_message.id)
    end
  end
end
