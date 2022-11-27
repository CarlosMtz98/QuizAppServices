require 'json'
require 'logger'
require_relative 'helpers/service_response'
require_relative 'helpers/json_helper'
require_relative 'repositories/question_repository'
require_relative 'question_service'

BASE_URI = '/question'

def lambda_handler(event:, context:)
  @logger = Logger.new($stdout)

  path = event.dig('requestContext', 'http', 'path')

  unless path.include? BASE_URI
    return ServiceResponse.not_found("Path #{path} not found")
  end

  @repository = QuestionRepository.instance(@logger)
  @question_service = QuestionService.new(@repository)
  method = event.dig('requestContext', 'http', 'method')
  case method
  when 'GET'
    handle_get(event)
  when 'POST'
    handle_post(event['body'])
  when 'PUT'
    handle_put(event.dig("queryStringParameters"), event['body'])
  when 'DELETE'
    handle_delete(event.dig("queryStringParameters"))
  else
    ServiceResponse.method_not_allowed(method, BASE_URI)
  end
end

def handle_post(body)
  @logger.info("question-service | handle_post | Start")
  begin
    question = parse_body(body)
    error = question.is_valid?
    if error.nil?
      new_question = @repository.create(question)
      ServiceResponse.create_success(new_question)
    else
      ServiceResponse.bad_request(error)
    end
  rescue Exception => ex
    ServiceResponse.error("Could not create the question Error: #{ex.message}")
  end
end

def parse_body(body)
  if body.nil?
    return ServiceResponse.bad_request("The request body is required")
  end
  JsonHelper.parse_question(body)
end

def handle_get(event)
  path = event.dig('requestContext', 'http', 'path')
  case
  when path.include?('/count')
    count = @repository.count
    ServiceResponse.service_response(200, { total_items: count })
  when path.include?('/random')
    questions = @question_service.get_random_questions(5)
    if questions.nil? || questions.length() == 0
      ServiceResponse.not_found("No questions found")
    else
      ServiceResponse.ok(questions)
    end
  else
    query = event.dig('queryStringParameters')
    if query.nil?
      questions = @repository.find
      ServiceResponse.ok(questions)
    else
      handle_get_with_query(query)
    end
  end
end

def handle_get_with_query(query)
  @logger.info("question-service | handle_get_with_query | Start")
  id = query.dig('id')
  unless id.nil?
    question = @repository.find_by(id)
    if question.nil?
      ServiceResponse.entity_not_found('question', id)
    else
      ServiceResponse.ok(question)
    end
  end
end

def handle_put(query, body)
  @logger.info("question-service | handle_put | Start")
  unless query.nil?
    id = query.dig('id')
    if @repository.find_by(id).nil?
      ServiceResponse.entity_not_found("question", id)
    end
    question = parse_body(body)
    if question.nil?
      ServiceResponse.bad_request("Could not parse the body for question update")
    else
      res = @repository.update(id, question)
      if res
        @logger.info("question-service | handle_put | Success | End")
        ServiceResponse.ok(question)
      else
        @logger.info("question-service | handle_put | Fail | End")
        ServiceResponse.error("Could not update the question with Id: #{id}")
      end
    end
  end
end

def handle_delete(query)
  @logger.info("question-service | handle_delete | Start")
  unless query.nil?
    id = query.dig('id')
    if @repository.find_by(id).nil?
      ServiceResponse.entity_not_found("question", id)
    else
      resp = @repository.delete(id)
      if resp
        ServiceResponse.service_response(200,{Id: id})
      else
        ServiceResponse.error('Could not delete the question')
      end
    end
  end
end
