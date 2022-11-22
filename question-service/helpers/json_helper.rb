require_relative '../entities/option'
require_relative '../entities/question'

class JsonHelper
  def self.parse_question(json)
    if json.nil?
      raise "Null json to be parse"
    end
    data_object = JSON.parse(json)
    options = data_object["options"].map { |opt| Option.new(opt.dig("id"), opt.dig("text"), opt.dig("isCorrect")) }
    Question.new(data_object.dig("id"), data_object["value"], options)
  end

  def self.parse_from_hash(data_object)
    if data_object.nil?
      raise "Null data object"
    end
    options = data_object["options"].map { |opt| Option.new(opt.dig("id"), opt.dig("text"), opt.dig("isCorrect")) }
    Question.new(data_object.dig("id"), data_object["value"], options)
  end
end