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

  def get_correct_answer(question_id, option_id)
    @logger.info('QuestionService | check_correct_answer | Start')
    unless question_id.nil?
      response = Faraday.get("#{@base_url}#{question_id}/correct-answer/option/#{option_id}")
      if !response.success?
        @logger.info('QuestionService | check_correct_answer | Failed')
        ServiceResponse.fail("Failed to check the correct answer")
      else
        res = JSON.parse(response.body)
        response_entity = res.dig('entity')
        @logger.info('QuestionService | check_correct_answer | Success')
        ServiceResponse.ok(response_entity)
      end
    end
  end
end
