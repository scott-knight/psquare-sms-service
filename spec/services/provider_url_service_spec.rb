# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProviderUrlService do
  let(:service)       { ProviderUrlService.new }
  let(:default_host)  { "https://#{Rails.application.routes.default_url_options[:host]}" }
  let(:ngrok_url)     { "4a0115683853.ngrok.io" }
  let(:full_ngrok)    { "https://#{ngrok_url}" }

  after(:each) do
    Rails.env = 'test' unless Rails.env.test?
  end

  describe 'initialization' do
    it 'should set the base AWS URL' do
      expect(service.provider1_url).to match(/jo3kcwlvke/)
    end

    it 'should set the specific provider urls' do
      expect(service.provider1_url).to match(/provider1/)
      expect(service.provider2_url).to match(/provider2/)
    end
  end

  describe 'instance method' do
    describe 'call_ngrok' do
      it 'should return nil if NOT Rails.env.development?' do
        expect(service.call_ngrok).to be_nil
      end

      it 'should return the ngrok url' do
        Rails.env = 'development'
        stub_ngrok

        expect(service.call_ngrok).to_not be_nil
        expect(service.public_url).to eql(full_ngrok)
      end

      it 'should log_message for rescued errors'
    end

    describe 'call_setup' do
      it 'should return true' do
        expect(service.call_setup).to be_truthy
      end
    end

    describe 'set_public_url' do
      it 'should set the default host in redis public_url' do
        sm = ProviderUrlService.new
        sm.set_public_url

        expect(sm.public_url).to eql(default_host)
      end

      it 'should set the ngrok url if Rails.env.development?' do
        Rails.env = 'development'
        stub_ngrok
        sm = ProviderUrlService.new

        expect(sm.public_url).to eql(full_ngrok)
      end

      it 'should log_message for rescued errors'
    end

    describe 'set_rails_host' do
      it 'should add the ngrok url to the Rails hosts settings if development' do
        Rails.env = 'development'
        stub_ngrok
        sm = ProviderUrlService.new

        expect(Rails.application.config.hosts).to include(ngrok_url)
      end

      it 'should log rescued errors'
    end
  end
end

def stub_ngrok
  stub_request(:get, "http://127.0.0.1:4040/api/tunnels").
  with(
    headers: {
	  'Accept'=>'*/*',
	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
	  'Host'=>'127.0.0.1:4040',
	  'User-Agent'=>'Ruby'
    }).
  to_return(
    status: 200,
    body: "{\"tunnels\":[{\"name\":\"command_line\",\"uri\":\"/api/tunnels/command_line\",\"public_url\":\"https://4a0115683853.ngrok.io\",\"proto\":\"https\",\"config\":{\"addr\":\"http://localhost:3000\",\"inspect\":true},\"metrics\":{\"conns\":{\"count\":0,\"gauge\":0,\"rate1\":0,\"rate5\":0,\"rate15\":0,\"p50\":0,\"p90\":0,\"p95\":0,\"p99\":0},\"http\":{\"count\":0,\"rate1\":0,\"rate5\":0,\"rate15\":0,\"p50\":0,\"p90\":0,\"p95\":0,\"p99\":0}}},{\"name\":\"command_line (http)\",\"uri\":\"/api/tunnels/command_line%20%28http%29\",\"public_url\":\"http://4a0115683853.ngrok.io\",\"proto\":\"http\",\"config\":{\"addr\":\"http://localhost:3000\",\"inspect\":true},\"metrics\":{\"conns\":{\"count\":0,\"gauge\":0,\"rate1\":0,\"rate5\":0,\"rate15\":0,\"p50\":0,\"p90\":0,\"p95\":0,\"p99\":0},\"http\":{\"count\":0,\"rate1\":0,\"rate5\":0,\"rate15\":0,\"p50\":0,\"p90\":0,\"p95\":0,\"p99\":0}}}],\"uri\":\"/api/tunnels\"}\n",
    headers: {}
  )
end