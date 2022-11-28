# Final Project: Quiz Application with Microservices
# Date: 28-Nov-2022
# Authors:
#          A01375577 Carlos Martínez
#          A01374561 Paco Murillo
# File: question_service.rb

require_relative 'services/service_response'

class QuestionService
  def initialize(logger, question_repo)
    @logger = logger
    @question_repository = question_repo
  end

  def get_question_by_id(id)
    begin
      unless id.nil?
        question = @question_repository.find_by(id)
        if question.nil?
          ServiceResponse.fail_code("Question not found", 404)
        else
          ServiceResponse.ok(ParserHelper.parse_from_hash(question))
        end
      end
    rescue Exception => ex
      ServiceResponse.fail_code(ex.message, 99)
    end
  end

  def delete_question(id)
    begin
      question_response = self.get_question_by_id(id)
      if !question_response.success
        question_response
      else
        response = @question_repository.delete(id)
        if !response
          ServiceResponse.fail_code(500, "Could not delete the question")
        else
          ServiceResponse.ok(id)
        end
      end
    rescue Exception => ex
      ServiceResponse.fail_code(ex.message, 99)
    end
  end

  def get_all_questions
    begin
      questions = @question_repository.find
      ServiceResponse.ok(questions)
    rescue Exception => ex
      ServiceResponse.fail_code(ex.message, 99)
    end
  end

  def get_random_questions(number)
    if number.nil? || number <= 0
      raise "Number param can't be null or less than 0"
    end

    questions = @question_repository.find

    if questions.nil? || questions.length() == 0
      raise "No questions where found"
    end

    questions.shuffle.take(number)
  end

  def get_correct_answer(question_id, option_id)
    @logger.info("question-service | QuestionService | get_correct_answer | Start | question: #{question_id} | option: #{option_id}")
    question_response = get_question_by_id(question_id)
    if question_response.success
      question = question_response.entity
      selected_option = question.options.find { |opt| opt.id == option_id }
      if selected_option.nil?
        ServiceResponse.fail_code("Question without option with id: #{option_id} not found", 404)
      else
        if selected_option.is_correct
          ServiceResponse.ok({ correct?: true, correctAnswer: nil })
        else
          correct_option = question.options.find { |opt| opt.is_correct }
          ServiceResponse.ok({ correct?: false, correctAnswer: correct_option.text })
        end
      end
    end
  end
end