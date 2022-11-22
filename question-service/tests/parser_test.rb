require 'minitest/autorun'
require 'json'
require 'securerandom'
require_relative '../helpers/json_helper'

class ParserTest < Minitest::Test
  def setup
    @obj_payload = self.object_payload
  end

  def string_payload
    "{\"id\":\"dfed675c-27c0-46aa-ada5-7a39f27a102d\",\"value\":\"test\",\"options\":[{\"id\":\"9558a88d-4093-4068-ad8e-23336418ef32\",\"text\":\"true\",\"isCorrect\":true},{\"id\":\"6f3cb428-bcaf-4485-a7db-5c2d536d9361\",\"text\":\"false\",\"isCorrect\":false}]}"
  end

  def object_payload
    {
      id: "dfed675c-27c0-46aa-ada5-7a39f27a102d",
          value: 'test',
          options: [
            {
              id: "9558a88d-4093-4068-ad8e-23336418ef32",
              text: 'true',
              isCorrect: true
            },
            {
              id: "6f3cb428-bcaf-4485-a7db-5c2d536d9361",
              text: 'false',
              isCorrect: false
            },
          ]
        }
  end

  def object_new_entity
    {
      value: 'test',
      options: [
        {
          text: 'true',
          isCorrect: true
        },
        {
          text: 'false',
          isCorrect: false
        },
      ]
    }
  end

  def test_question_object_parse
    json = JSON.generate(@obj_payload)
    assert json != nil?
    assert_equal string_payload, json
  end

  def test_question_parser_string
    json = string_payload
    assert !json.nil?
    assert !json.empty?
    question = JsonHelper.parse_question(json)
    assert !question.nil?, "Expecting to construct a question object"
  end

  def test_question_parser_object
    json = JSON.generate(object_new_entity)
    assert !json.nil?
    assert !json.empty?
    question = JsonHelper.parse_question(json)
    assert !question.nil?, "Expecting to construct a question object"
  end

  def test_create_object_hash
    question = Question.new(nil, "test", [Option.new(nil, "Hello", true), Option.new(nil , "World", false)])
    question.set_created_date
    res = question.to_hash
    assert !res.nil?
  end

  def test_delete_key_hash
    question = Question.new(nil, "test", [Option.new(nil, "Hello", true), Option.new(nil , "World", false)])
    hash = question.set_updated_date.to_hash
    hash.delete('Id')
    assert hash != nil
  end
end