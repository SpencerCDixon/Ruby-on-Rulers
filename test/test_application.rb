require_relative 'test_helper'

class TestController < Rulers::Controller
  def index
    "Hello!"
  end
end

class TestApp < Rulers::Application
  def get_controller_and_action(env)
    [TestController, "index"]
  end
end

class RulersAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    TestApp.new
  end

  def test_request
    get '/example/route'

    assert last_response.ok?
    body = last_response.body
    assert body["Hello"]
  end

  def test_array_helper
    array = [1,2,3,4]

    assert 10, array.sum
    assert 1, array.first
    assert 2, array.second
    assert 3, array.third
    assert 4, array.fourth
  end
end
