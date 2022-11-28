# Final Project: Quiz Application with Microservices
# Date: 28-Nov-2022
# Authors:
#          A01375577 Carlos Martínez
#          A01374561 Paco Murillo
# File: service_response.rb

class ServiceResponse
  attr_reader :success, :entity, :status_detail, :error_code
  def initialize(success, entity, status_detail, error_code)
    @success = success
    @entity = entity
    @status_detail = status_detail
    @error_code = error_code
  end

  def self.ok(entity)
    self.new(true, entity, 'success', 0)
  end

  def self.fail(message)
    self.new(false, nil, message, 99)
  end

  def self.fail_code(message, error_code)
    self.new(false, nil, message, error_code)
  end
end