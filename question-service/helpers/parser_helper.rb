require_relative '../entities/option'
require_relative '../entities/question'

class ParserHelper
  def self.parse_question(json)
    if json.nil?
      raise "Null json to be parse"
    end
    data_object = JSON.parse(json)
    self.parse_from_hash(data_object)
  end

  def self.parse_from_hash(data_object)
    if data_object.nil?
      raise "Null data object"
    end
    id = data_object.dig("id")
    value = data_object.dig("value")
    category = data_object.dig("category")
    options = data_object["options"].map { |opt| Option.new(opt.dig("id"), opt.dig("text"), opt.dig("isCorrect")) }
    Question.new(id, value, category , options)
  end
end