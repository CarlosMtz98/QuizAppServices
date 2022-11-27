require_relative '../lambda_function'
require 'minitest/autorun'
require 'json'
require 'logger'
require 'aws-xray-sdk/lambda'

XRay.recorder.configure({ context_missing: 'LOG_ERROR' })

class TestFunction < Minitest::Test
  logger = Logger.new($stdout)

  def test_invoke
    file_name = "#{__dir__}/event.json"
    exists = File.exists?(file_name)
    assert exists
    file = File.read(file_name)
    event = JSON.parse(file)
    context = Hash.new
    result = lambda_handler(event: event, context: context)
    assert_match('function_count', result.to_s, 'Should match')
  end

  def test_post_create_quiz
    file_name = "#{__dir__}/scripts/post_create_quiz.json"
    exists = File.exists?(file_name)
    assert exists
    file = File.read(file_name)
    event = JSON.parse(file)
    context = Hash.new
    result = lambda_handler(event: event, context: context)
    assert_match('function_count', result.to_s, 'Should match')
  end

  def test_get_quiz

  end

  def test_get_quizzes

  end

end