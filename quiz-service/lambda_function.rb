require 'json'
require 'logger'
require 'faraday'
require_relative 'services/question_service'
require_relative 'repositories/quiz_repository'
require_relative 'helpers/http_response'
require_relative 'helpers/parser_helper'
require_relative 'entities/answer'

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
    handle_post(path, body)
  when 'PUT'
    handle_put(path, body)
  else
    HttpResponse.method_not_allowed(method, BASE_URI)
  end
end

def handle_get(path, query)
  id = get_entity_url_id(path, 'quiz')
  if path.include?('/top-scores')
    limit = get_entity_url_id(path, 'top-scores')
    quizzes_data = @repository.find_top
    if quizzes_data.nil?
      HttpResponse.not_found("No quizzes found")
    else
      quizzes = quizzes_data.map { |qd| ParserHelper.parse_from_hash(qd) }.sort { |quiz| -quiz.grade }
      if limit
        quizzes = quizzes.take(limit)
      end
      HttpResponse.service_response(200, quizzes.map { |q| q.to_hash } )
    end
  elsif !id.nil?
    quiz = @repository.find_by(id)
    if quiz.nil?
      HttpResponse.entity_not_found('Quiz', id)
    else
      HttpResponse.ok(quiz.item)
    end
  elsif !query.nil?
    quizzes = @repository.find_with_query(query, limit)
    HttpResponse.ok(200, quizzes)
  else
    # get all quizzes
    HttpResponse.service_response(200, {})
  end
end

def handle_post(path, body)
  if path.include?('/finish')
    quiz_id = get_entity_url_id(path, 'quiz')
    if quiz_id.nil?
      HttpResponse.bad_request("The quiz id is a required parameter")
    else
      quiz_data = @repository.find_by(quiz_id)
      if quiz_data.nil?
        HttpResponse.entity_not_found('Quiz', id)
      else
        quiz = ParserHelper.parse_from_hash(quiz_data.item)
        if quiz.nil?
          HttpResponse.service_response(422, message: 'Could not finish the quiz')
        end
        update_response = @repository.update(quiz_id, quiz.finish)
        if update_response.nil? || update_response.attributes.nil?
          HttpResponse.service_response(422, message: 'Could not update the quiz')
        else
          res = update_response.attributes
          obj = ParserHelper.parse_from_hash(res)
          HttpResponse.ok(obj.to_hash)
        end
      end
    end
  else
    if body.nil?
      HttpResponse.bad_request('The quiz request body is required')
    end
    new_quiz = ParserHelper.parse_from_json(body)
    if new_quiz.is_a? Quiz
      questions_response = @question_service.get_random_questions
      if questions_response.success
        new_quiz.set_questions(questions_response.entity).set_quantity
      end
      res = @repository.create(new_quiz)
      if res.nil?
        HttpResponse.error("Could not create response")
      else
        HttpResponse.ok({ id: new_quiz.id, user_name: new_quiz.user_name, questions: new_quiz.questions, quantity: new_quiz.quantity })
      end
    else
      HttpResponse.bad_request('Could not generate quiz from body')
    end
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
  quiz = @repository.find_by(id)
  if quiz.nil?
    HttpResponse.entity_not_found('Quiz', id)
  else
    if path.include?('add-answer')
      data = JSON.parse(body)
      question_id = data.dig('questionId')
      option_id = data.dig('optionId')

      if question_id.nil?
        HttpResponse.bad_request('The questionId inside the request body is required')
      elsif option_id.nil?
        HttpResponse.bad_request('The optionId inside the request body is required')
      else
        correct_answer_response = @question_service.get_correct_answer(question_id, option_id)
        if !correct_answer_response.success
          HttpResponse.error(correct_answer_response.status_detail)
        else
          is_correct = correct_answer_response.entity.dig('correct?')
          correct_answer = correct_answer_response.entity.dig('correctAnswer?')
          answer = Answer.new(nil, is_correct, correct_answer, question_id).set_id.set_created_date
          res = @repository.add_answers(id, answer)
          if res.nil?
            HttpResponse.service_response(422, message: "Could not add the question answer to the quiz Id: #{id}")
          else
            HttpResponse.ok(correct_answer_response.entity)
          end
        end
      end
  else
    HttpResponse.method_not_allowed('PUT', 'quiz')
    end
  end
end

def get_entity_url_id(url, entity_name)
  id = url.match /\/#{entity_name}\/([\w|-]+)/
  unless id.nil?
    id[1]
  end
end