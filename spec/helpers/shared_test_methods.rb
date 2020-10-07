# frozen_string_literal: true
# :nocov:

module SharedTestMethods
  extend RSpec::SharedContext

  SMS_SERVICE_URL = 'https://jo3kcwlvke.execute-api.us-west-2.amazonaws.com/dev/provider2'

  def json_parse(json)
    Oj.load(json, symbol_keys: true)
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

  def stub_sms_service_success(url = SMS_SERVICE_URL)

  end

  def stub_sms_service_failure(url = SMS_SERVICE_URL)

  end
end
# :nocov: