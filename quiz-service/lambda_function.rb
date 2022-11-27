require 'json'
require 'logger'
require_relative 'services/question_service'
require_relative 'repositories/quiz_repository'
require_relative 'helpers/http_response'
require_relative 'helpers/parser_helper'

BASE_URI ='/quiz'
QUESTION_SERVICE_URL = 'https://z7lgc2pcsp7rrhpx3p5zyu3dhi0afpdf.lambda-url.us-east-1.on.aws/question/'

def lambda_handler(event:, context:)
  @logger = Logger.new($stdout)
  @repository = QuizRepository.instance(@logger)
  @question_service = QuestionService.new(@logger, QUESTION_SERVICE_URL)
  path = event.dig('requestContext', 'http', 'path')

  unless path.include? BASE_URI
    return HttpResponse.not_found("Path #{path} not found")
  end

  method = event.dig('requestContext', 'http', 'method')
  body = event.dig('body')
  case method
  when 'GET'
    query = event.dig('queryStringParameters')
    handle_get(path, query)
  when 'POST'
    handle_post(body)
  when 'PUT'
    handle_put(path, body)
  when 'DELETE'
    handle_delete(path)
  else
    HttpResponse.method_not_allowed(method, BASE_URI)
  end
end

def handle_get(path, query)
  id = get_entity_url_id(path, 'quiz')
  if !id.nil?
    # findBy Id
    HttpResponse.service_response(200, id)
  elsif !query.nil?
    # findWith Params
    HttpResponse.service_response(200, query)
  else
    # get all quizzes
    HttpResponse.service_response(200, {})
  end
end

def handle_post(body)
  if body.nil?
    HttpResponse.bad_request('The quiz request body is required')
  end
  new_quiz = ParserHelper.parse_from_json(body)
  if new_quiz.is_a? Quiz
    questions = @question_service.get_random_questions
    new_quiz.set_questions(questions)
    res = @repository.create(new_quiz)
    HttpResponse.ok(res)
  else
    HttpResponse.bad_request('Could not generate quiz from body')
  end
end

def handle_put(path, body)
  id = get_entity_url_id(path, 'quiz')
  if id.nil?
    HttpResponse.bad_request('The quiz id param is required')
  end

  if body.nil?
    HttpResponse.bad_request('The quiz request body is required')
  end
  quiz = ParserHelper.parse_from_json(body)
end

def handle_delete(path)
  id = get_entity_url_id(path, 'quiz')
  if id.nil?
    HttpResponse.bad_request('The quiz id param is required')
  end
end

def get_entity_url_id(url, entity_name)
  id = url.match /\/#{entity_name}\/(\d+)/
  unless id.nil?
    id[1]
  end
end


