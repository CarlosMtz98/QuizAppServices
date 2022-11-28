require_relative '../lambda_function'
require 'minitest/autorun'
require 'json'
require 'logger'
require 'aws-xray-sdk/lambda'

XRay.recorder.configure({ context_missing: 'LOG_ERROR' })

class TestFunction < Minitest::Test
  logger = Logger.new($stdout)

  def setup
  end

  def test_set_env_var
    assert ENV['AWS_REGION']
    assert ENV['AWS_ACCESS_KEY_ID']
    assert ENV['AWS_SECRET_ACCESS_KEY']
  end

  def test_get_count
    assert ENV['AWS_REGION']
    assert ENV['AWS_ACCESS_KEY_ID']
    assert ENV['AWS_SECRET_ACCESS_KEY']
    file_name = "#{__dir__}/scripts/get_questions_count_test.json"
    assert File.exists?(file_name)
    file = File.read(file_name)
    event = JSON.parse(file)
    context = Hash.new
    result = lambda_handler(event: event, context: context)
    assert result["statusCode"] == 200
  end

  def test_get_random_question
    file_name = "#{__dir__}/scripts/get_random_questions_test.json"
    assert File.exists?(file_name)
    file = File.read(file_name)
    event = JSON.parse(file)
    context = Hash.new
    result = lambda_handler(event: event, context: context)
    assert result["statusCode"] == 200
  end

  def test_get_question_correct_answer
    file_name = "#{__dir__}/scripts/get_correct_answer_test.json"
    assert File.exists?(file_name)
    file = File.read(file_name)
    event = JSON.parse(file)
    context = Hash.new
    result = lambda_handler(event: event, context: context)
    assert result["statusCode"] == 200
  end
end