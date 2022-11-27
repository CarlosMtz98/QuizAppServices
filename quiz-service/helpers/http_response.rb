require 'json'
require_relative 'http_helpers'

class HttpResponse
  def self.service_response(code, body)
    {
      statusCode: code,
      headers: {
        "Content-type" => "application/json; charset=utf-8"
      },
      body: JSON.generate(body)
    }
  end

  def self.success(status, entity)
    unless status == HttpStatus::OK || status == HttpStatus::CREATED
      raise "Wrong status for the current response"
    end

    if entity.nil?
      raise "Entity can not be null"
    end

    body = {
      is_success: true,
      entity: entity
    }

    self.service_response(status, body)
  end

  def self.ok(entity)
    self.success(HttpStatus::OK, entity)
  end

  def self.create_success(entity)
    self.success(HttpStatus::CREATED, entity)
  end

  def self.bad_request(message)
    self.fail(HttpStatus::BAD_REQUEST, message)
  end

  def self.not_found(message)
    self.fail(HttpStatus::NOT_FOUND, message)
  end

  def self.entity_not_found(entity_name, id)
    message = "The #{entity_name} with id: #{id} wasn't found"
    self.fail(HttpStatus::NOT_FOUND, message)
  end

  def self.method_not_allowed(method, scope)
    message = "The method #{method} is not allowed for #{scope}"
    self.fail(HttpStatus::NOT_FOUND, message)
  end

  def self.error(message)
    self.fail(HttpStatus::SERVER_ERROR, message)
  end


  def self.fail(status, message)
    if status == HttpStatus::OK || status == HttpStatus::CREATED
      raise "Fail Status code"
    end

    body = {
      is_success: false,
      status_detail: message
    }

    self.service_response(status, body)
  end
end