require_relative 'entity_base'

class Option < EntityBase
  attr_reader :is_correct, :text
  def initialize(id, text, is_correct)
    @text = text
    @is_correct = is_correct
    super(id)
  end

  def is_valid?
    if @text.nil? || @text.empty?
      "Option text is required"
    end

    if @is_correct.nil?
      "Option correct answer is required"
    end
  end

  def to_hash
    { "id" => @id, "text" => @text, "isCorrect" => @is_correct }
  end

  def update_hash
    { "text" =>
        {'value' => @text, 'action' => 'PUT'},
      "isCorrect" =>
        { 'value' => @is_correct, 'action' => 'PUT'} }
  end
end