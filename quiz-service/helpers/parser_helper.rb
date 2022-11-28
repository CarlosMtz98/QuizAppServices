require 'json'
require_relative '../entities/quiz'
require_relative '../entities/answer'

class ParserHelper
  def self.parse_from_json(json)
    if json.nil?
      raise "Null json object"
    end

    data_object = JSON.parse(json)
    parse_from_hash(data_object)
  end

  def self.parse_from_hash(data_object)
    if data_object.nil?
      raise "Null data object"
    end
    id = data_object.dig('id')
    user_name = data_object.dig('userName')
    quantity = data_object.dig('quantity')
    status = get_status(data_object.dig('status'))
    grade = data_object.dig('grade')
    category = data_object.dig('category')
    answers_data_object = data_object.dig('answers')
    questions = data_object.dig('questions')
    answers = nil

    unless answers_data_object.nil?
      answers = answers_data_object.map { |ans| self.parse_answer_from_hash(ans) }
    end

    Quiz.new(id, user_name, status, quantity.to_i, grade.to_i, category, questions, answers)
  end

  def self.parse_answer_from_hash(data_object)
    unless data_object.nil?
      id = data_object.dig('id')
      is_correct = data_object.dig('isCorrect')
      correct_answer = data_object.dig('correctAnswer')
      question_id = data_object.dig('questionId')
      Answer.new(id, is_correct, correct_answer, question_id)
    end
  end

  def self.get_status(status)
    if status.nil?
      QuizStatus::UNKNOWN
    else
      if status.is_a? Integer
        case status
        when 0
          QuizStatus::ONGOING
        when 1
          QuizStatus::FINISHED
        when 2
          QuizStatus::ABANDONED
        else
          QuizStatus::UNKNOWN
        end
      elsif  status.is_a? String
        case status.downcase
        when 'ongoing'
          QuizStatus::ONGOING
        when 'finished'
          QuizStatus::FINISHED
        when 'abandoned'
          QuizStatus::ABANDONED
        else
          QuizStatus::UNKNOWN
        end
      else
        QuizStatus::UNKNOWN
      end
    end
  end
end