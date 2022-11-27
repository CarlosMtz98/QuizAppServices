module Repository
  def instance(logger)
    raise "Not implemented"
  end

  def count
    raise "Not yet implemented"
  end

  def find
    raise "Not implemented yet"
  end

  def find_by(id)
    raise "Not implemented yet"
  end

  def create(entity)
    raise "Not implemented yet"
  end

  def update(id, entity)
    raise "Not implemented yet"
  end

  def delete(id)
    raise "Not implemented yet"
  end

  def is_valid_entity?(entity)
    raise "Not implemented yet"
  end
end