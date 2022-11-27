require 'json'
require 'faraday'

class QuestionService
  def initialize(url)
    @base_url = url
  end

  def get_random_questions(number)
    response = Faraday.get("#{@base_url}/random")
    if !response.success?
      raise "Error fetching data from QuestionService ErrorCode: #{response.code}"
    else
      res = JSON.parse(response)
      questions = res.entity
    end
  end
end
