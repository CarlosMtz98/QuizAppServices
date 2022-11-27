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

  def create(entity)
    @logger.info("quiz-service | QuizRepository | create | Start")
    if is_valid_entity?(entity)
      begin
        item = entity.set_id.set_created_date
        response = @client.put_item(table_name: @table_name, item: item.to_hash)
        if response.successful?
          @logger.info("question-service | QuizRepository | create | Success")
          response
        else
          @logger.error("question-service | QuizRepository | create | Failed")
        end
      rescue Exception => ex
        @logger.fatal("question-service | QuizRepository | create | Failed | Exception #{ex.message}")
      end
    else
      @logger.error("question-service | QuizRepository | create | Failed | Invalid Class type")
    end
  end

  def is_valid_entity?(entity)
    entity.is_a?(Quiz)
  end
end