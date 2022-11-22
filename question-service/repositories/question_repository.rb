require 'aws-sdk-dynamodb'
require 'json'
require_relative 'repository'
require_relative '../entities/question'

class QuestionRepository
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

  def find
    begin
      @client.scan(table_name: @table_name).items
    rescue Exception => ex
      @logger.fatal("question-service | QuestionRepository | find | Exception", ex)
    end
  end

  def find_by(id)
    begin
      response = @client.get_item(table_name: @table_name, key: { Id: id })
      unless response.nil? && response.item.nil?
        response.item
      end
    rescue Exception => ex
      @logger.fatal("question-service | QuestionRepository | find | Exception", ex)
    end
  end

  def create(entity)
    @logger.info("question-service | QuestionRepository | create | Start")
    if self.is_valid_entity?(entity)
      error = entity.is_valid?
      if error.nil?
        begin
          question = @client.put_item(table_name: @table_name, item: entity.set_id.set_created_date.to_hash)
          @logger.info("question-service | QuestionRepository | create | Success | Id: #{question}")
          return question
        rescue Exception => ex
          @logger.error("question-service | QuestionRepository | Exception #{ex.message}")
        end
      else
        @logger.error("question-service | QuestionRepository | Question object is invalid")
        raise Exception.new"Unable to persist Question object, Error: #{error}"
      end
    end
  end

  def update(entity)
    unless entity.nil?
      if entity.is_valid?
        query =  { Id: entity.id }
        question = entity.set_updated_date.to_hash
        question.delete('Id')
        @client.update_item(table_name: @table_name, key: query, attribute_updates: question)
      end
    end
  end

  def delete(id)
    super
  end

  def is_valid_entity?(entity)
    entity.is_a?(Question)
  end
end