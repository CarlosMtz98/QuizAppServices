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
    hash = { "Id" => @id }
    unless @created_date.nil?
      hash['CreatedDate'] = @created_date.to_s
    end

    unless @updated_date.nil?
      hash['UpdatedDate'] = @updated_date.to_s
    end

    unless @deleted_date.nil?
      hash['DeletedDate'] = @deleted_date.to_s
    end
    hash
  end
end