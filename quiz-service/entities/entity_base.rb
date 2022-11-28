require 'securerandom'

class EntityBase
  attr_reader :id

  def initialize(id)
    unless id.nil?
      @id = id
    end
  end

  def set_id(id = nil)
    if id.nil?
      @id = SecureRandom.uuid
    else
      @id = id
    end
    self
  end

  def set_created_date
    @created_date = Time.now.utc
    self
  end

  def set_updated_date
    @updated_date = Time.now.utc
    self
  end

  def set_deleted_date
    @deleted_date = Time.now.utc
    self
  end

  def to_h
    hash = { "id" => @id }
    unless @created_date.nil?
      hash['createdDate'] = @created_date.to_s
    end

    unless @updated_date.nil?
      hash['updatedDate'] = @updated_date.to_s
    end

    unless @deleted_date.nil?
      hash['deletedDate'] = @deleted_date.to_s
    end
    hash
  end
end