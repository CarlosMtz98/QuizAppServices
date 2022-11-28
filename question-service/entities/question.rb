# Final Project: Quiz Application with Microservices
# Date: 28-Nov-2022
# Authors:
#          A01375577 Carlos Martínez
#          A01374561 Paco Murillo
# File: question.rb

require_relative 'option'
require_relative 'entity_base'

class Question < EntityBase
  attr_reader :options
  def initialize(id, value, category, options)
    @value = value
    @category = category
    @options = options.nil? ? [] : options
    super(id)
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

  def set_options_id
    @options.each { |opt| opt.set_id }
    self
  end

  def to_hash
    base = self.to_h
    hash = {"value" => @value,
            "category" => @category,
            "options" => @options.map { |opt| opt.to_hash }}
    base.merge(hash)
  end

  def update_hash
    {
      'value' => { 'value' => @value, 'action' => 'PUT' },
      'category' => { 'value' => @category, 'action' => 'PUT' },
      'updatedDate' => { 'value' => @updated_date.to_s, 'action' => 'PUT'},
      'options' => {'value' => @options.map { |opt| opt.to_hash }, 'action' => 'PUT'}
    }
  end
end