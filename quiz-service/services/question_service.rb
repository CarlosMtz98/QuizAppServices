require 'json'
require 'faraday'
require_relative 'service_response'

class QuestionService
  def initialize(logger, url)
    @logger = logger
    @base_url = url
  end

  def get_random_questions
    @logger.info('QuestionService | get_random_questions | Start')
    response = Faraday.get("#{@base_url}/random")
    if !response.success?
      @logger.info('QuestionService | get_random_questions | Failed')
      ServiceResponse.fail("Failed to get random questions")
    else
      res = JSON.parse(response.body)
      questions = res.dig('entity')
      @logger.info('QuestionService | get_random_questions | Success')
      ServiceResponse.ok(questions)
    end
  end
end
