require 'aws-sdk-dynamodb'
require 'json'
require_relative 'repository'

class QuizRepository
  include Repository
  private_class_method :new

  def initialize(log_instance)
    @logger = log_instance
    @table_name = ENV["TABLE_NAME"]
    @client = Aws::DynamoDB::Client.new
  end

  def self.instance(logger)
    return @instance if @instance
    @instance ||= new(logger)
  end

  def count
    @logger.info("quiz-service | QuizRepository | count | Start")
    begin
      @client.scan(table_name: @table_name, select: "COUNT").count
    rescue Exception => ex
      @logger.fatal("quiz-service | QuizRepository | count | Exception: #{ex.message}")
    end
  end

  def find_with_query(query, limit)
    begin
      limit.nil? ? 10 : limit
      res = @client.scan(table_name: @table_name, scan_filter: query).items
      unless res.items.nil?
        return res.items
      end
    rescue Exception => ex
      @logger.fatal("question-service | QuestionRepository | find | Exception: #{ex.message}",)
    end
  end

  def find_top
    begin
      project = 'id, username, grade, category, createdDate'
      res = @client.scan(table_name: @table_name, projection_expression: project)
      unless res.items.nil?
        return res.items
      end
    rescue Exception => ex
      @logger.fatal("question-service | QuestionRepository | find | Exception: #{ex.message}",)
    end
  end

  def find_by(id)
    @logger.info("quiz-service | QuizRepository | find_by | Start | id: #{id || ''}")
    unless id.nil?
      begin
        res = @client.get_item(table_name: @table_name, key: { id: id })
        @logger.info("quiz-service | QuizRepository | find_by | #{res.successful? ? 'Success' : 'Failed'}")
        unless res.item.nil?
          return res
        end
      rescue Exception => ex
        @logger.fatal("quiz-service | QuizRepository | find_by | Exception: #{ex.message}")
      end
    end
    nil
  end

  def create(entity)
    @logger.info("quiz-service | QuizRepository | create | Start")
    if is_valid_entity?(entity)
      begin
        item = entity.set_id.set_created_date
        response = @client.put_item(table_name: @table_name, item: item.to_hash)
        if response.successful?
          @logger.info("question-service | QuizRepository | create | Success")
          return response
        else
          @logger.error("question-service | QuizRepository | create | Failed")
        end
      rescue Exception => ex
        @logger.fatal("question-service | QuizRepository | create | Failed | Exception #{ex.message}")
      end
    else
      @logger.error("question-service | QuizRepository | create | Failed | Invalid Class type")
    end
    nil
  end

  def add_answers(id, answer)
    @logger.info("quiz-service | QuizRepository | add_answers | Start")
    if !id.nil? && !answer.nil?
      begin
        update_expression = 'SET #answers = list_append(if_not_exists(#answers, :empty_list), :quiz_answers)'
        res = @client.update_item(
          table_name: @table_name,
          key: { id: id },
          return_values: 'ALL_NEW',
          update_expression: update_expression,
          expression_attribute_names: {
            '#answers' => 'answers'
          },
          expression_attribute_values: {
            ':quiz_answers' =>  [answer.to_hash],
            ':empty_list' => []
          }
        )
        @logger.info("quiz-service | QuizRepository | add_answers | #{res.successful? ? 'Success' : 'Failed'}")
        return res.successful?
      rescue Exception => ex
        @logger.fatal("quiz-service | QuizRepository | add_answers | Exception: #{ex.message}")
      end
    end
    nil
  end

  def update(id, entity)
    @logger.info("quiz-service | QuizRepository | update | Start")
    unless entity.nil?
      error = entity.is_valid?
      if error.nil?
        @logger.info("quiz-service | QuizRepository | update | IsValid")
        query =  { id: id }
        quiz = entity.set_updated_date.update_hash
        @logger.info("quiz-service | QuizRepository | update | IsValid")
        response = @client.update_item(table_name: @table_name, key: query, attribute_updates: quiz, return_values: 'ALL_NEW',)
        @logger.info("quiz-service | QuizRepository | update | End")
        return response
      else
        @logger.info("quiz-service | QuizRepository | update | Invalid quiz #{error}")
      end
    end
    nil
  end

  def is_valid_entity?(entity)
    if entity.nil?
      false
    elsif !entity.is_a?(Quiz)
      false
    else
      true
    end
  end
end