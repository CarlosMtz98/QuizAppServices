require 'json'
require_relative '../entities/quiz'

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
    Quiz.new(id, user_name, status, quantity, grade, category)
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