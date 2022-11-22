require_relative 'option'
require_relative 'entity_base'

class Question < EntityBase
  def initialize(id, value, options)
    @value = value
    @options = options.nil? ? [] : options
    super(id)
  end

  def update(value)

  end

  def add_option(option)
    if !option.nil? && option.is_valid?
    end
  end

  def remove_option(option_id)
    if option_id.nil?
      raise "The option_id is required"
    end
    opt = @options.select { |opt| opt.id == option_id }
  end

  def is_valid?
    if @value.nil? || @value.empty?
      "The value member is required"
    end

    if @options.nil? || @options.empty?
      "Options are required"
    end

    if @options.any? { |opt| opt.nil? || !opt.is_valid?.nil? }
      "There are invalid options"
    end
  end

  def to_hash
    base = self.to_h
    hash = {"text" => @value,
            "options" => @options.map { |opt| opt.to_hash }}
    base.merge(hash)
  end
end