require 'json'
require 'logger'
require_relative 'helpers/http_response_helper'
require_relative 'helpers/parser_helper'
require_relative 'repositories/question_repository'
require_relative 'question_service'

BASE_URI = '/question'

def lambda_handler(event:, context:)
  @logger = Logger.new($stdout)

  path = event.dig('requestContext', 'http', 'path')

  unless path.include? BASE_URI
    return HttpResponse.not_found("Path #{path} not found")
  end

  @repository = QuestionRepository.instance(@logger)
  @question_service = QuestionService.new(@logger, @repository)
  method = event.dig('requestContext', 'http', 'method')
  case method
  when 'GET'
    handle_get(event)
  when 'POST'
    handle_post(event['body'])
  when 'PUT'
    handle_put(path, event['body'])
  when 'DELETE'
    handle_delete(path)
  else
    HttpResponse.method_not_allowed(method, BASE_URI)
  end
end

def handle_post(body)
  @logger.info("question-service | handle_post | Start")
  begin
    question = parse_body(body)
    error = question.is_valid?
    if error.nil?
      new_question = @repository.create(question)
      if new_question
        HttpResponse.create_success(question.to_hash)
      else
        HttpResponse.service_response(422, {message: "Could not create the question"})
      end
    else
      HttpResponse.bad_request(error)
    end
  rescue Exception => ex
    HttpResponse.error("Could not create the question Error: #{ex.message}")
  end
end

def parse_body(body)
  if body.nil?
    return HttpResponse.bad_request("The request body is required")
  end
  ParserHelper.parse_question(body)
end

def handle_get(event)
  path = event.dig('requestContext', 'http', 'path')
  case

  when path.include?('/count')
    count = @repository.count
    HttpResponse.service_response(200, { total_items: count })

  when path.include?('/random')
    random_num_str = get_entity_url_id(path, 'random')
    num = random_num_str.nil? ? 5 : random_num_str.to_i
    questions = @question_service.get_random_questions(num)
    if questions.nil? || questions.length() == 0
      HttpResponse.not_found("No questions found")
    else
      HttpResponse.ok(questions)
    end

  when path.include?('/add-answer')
    question_id = get_entity_url_id(path, 'question')
    option_id = get_entity_url_id(path, 'option')
    if question_id.nil?
      HttpResponse.bad_request("Question id param is required")
    elsif option_id.nil?
      HttpResponse.bad_request("Option id param is required")
    else
      service_response = @question_service.get_correct_answer(question_id, option_id)
      handle_service_response(service_response)
    end

  else
    query = event.dig('queryStringParameters')
    if query.nil?
      questions = @repository.find
      HttpResponse.ok(questions)
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
      HttpResponse.entity_not_found('question', id)
    else
      HttpResponse.ok(question)
    end
  end
end

def handle_put(path, body)
  @logger.info("question-service | handle_put | Start")
  unless path.nil?
    id = get_entity_url_id(path, 'question')
    if id.nil?
      HttpResponse.bad_request('The id is required to update the question')
    end
    if @repository.find_by(id).nil?
      HttpResponse.entity_not_found("question", id)
    end
    question = parse_body(body)
    if question.nil?
      HttpResponse.bad_request("Could not parse the body for question update")
    else
      res = @repository.update(id, question)
      if res
        @logger.info("question-service | handle_put | Success | End")
        HttpResponse.ok(question)
      else
        @logger.info("question-service | handle_put | Fail | End")
        HttpResponse.error("Could not update the question with Id: #{id}")
      end
    end
  end
end

def handle_delete(path)
  @logger.info("question-service | handle_delete | Start")
  unless path.nil?
    id = get_entity_url_id(path, 'question')
    if id.nil?
      HttpResponse.bad_request("Id route param is required to delete question")
    elsif @repository.find_by(id).nil?
      HttpResponse.entity_not_found("question", id)
    else
      if @repository.delete(id)
        HttpResponse.service_response(200, { message: "Question id: #{id} deleted successfully"})
      else
        HttpResponse.error('Could not delete the question')
      end
    end
  end
end

def get_entity_url_id(url, entity_name)
  id = url.match /\/#{entity_name}\/([\w|-]+)/
  unless id.nil?
    id[1]
  end
end

def handle_service_response(service_response)
  if service_response.success
    HttpResponse.ok(service_response.entity)
  else
    case service_response.error_code
    when 400
      HttpResponse.bad_request(service_response.status_detail)
    when 404
      HttpResponse.not_found(service_response.status_detail)
    when 405
      HttpResponse.method_not_allowed(service_response.status_detail)
    else
      HttpResponse.error(service_response.status_detail)
    end
  end
end