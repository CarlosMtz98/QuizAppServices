# Final Project: Quiz Application with Microservices
# Date: 28-Nov-2022
# Authors:
#          A01375577 Carlos Martínez
#          A01374561 Paco Murillo
# File: question_repository.rb

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
      response = @client.get_item(table_name: @table_name, key: { id: id })
      unless response.nil? && response.item.nil?
        response.item
      end
    rescue Exception => ex
      @logger.fatal("question-service | QuestionRepository | find_by | Exception: #{ex.message}")
      nil
    end
  end

  def create(entity)
    @logger.info("question-service | QuestionRepository | create | Start")
    if self.is_valid_entity?(entity)
      error = entity.is_valid?
      if error.nil?
        begin
          response = @client.put_item(table_name: @table_name, item: entity.set_id.set_options_id.set_created_date.to_hash)
          @logger.info("question-service | QuestionRepository | create | Success")
          response.successful?
        rescue Exception => ex
          @logger.error("question-service | QuestionRepository | create | Exception #{ex.message}")
        end
      else
        @logger.error("question-service | QuestionRepository | create | Question object is invalid")
        raise Exception.new"Unable to persist Question object, Error: #{error}"
      end
    end
  end

  def update(id, entity)
    @logger.info("question-service | QuestionRepository | update | Start")
    unless entity.nil?
      error = entity.is_valid?
      if error.nil?
        @logger.info("question-service | QuestionRepository | update | IsValid")
        query =  { id: id }
        question = entity.set_updated_date.update_hash
        response = @client.update_item(table_name: @table_name, key: query, attribute_updates: question)
        @logger.info("question-service | QuestionRepository | update | End")
        response.successful?
      else
        @logger.info("question-service | QuestionRepository | update | Invalid question #{error}")
      end
    end
  end

  def delete(id)
    @logger.info("question-service | QuestionRepository | delete | Start")
    unless id.nil?
      query = { id: id }
      response = @client.delete_item(table_name: @table_name, key: query)
      @logger.info("question-service | QuestionRepository | delete | End")
      response.successful?
    end
  end

  def is_valid_entity?(entity)
    entity.is_a?(Question)
  end

  def count
    begin
      @client.scan(table_name: @table_name, select: "COUNT").count
    rescue Exception => ex
      @logger.info("question-service | QuestionRepository | update | Invalid question #{error}")
    end
  end
end