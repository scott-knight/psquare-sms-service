# frozen_string_literal: true
# :nocov:

module SharedTestMethods
  extend RSpec::SharedContext

  def json_parse(json)
    Oj.load(json, symbol_keys: true)
  end
end
# :nocov: