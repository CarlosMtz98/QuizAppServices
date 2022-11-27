class ServiceResponse
  def initialize(success, entity, status_details, error_code)
    @success = success
    @entity = entity
    @status_detail = status_details
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