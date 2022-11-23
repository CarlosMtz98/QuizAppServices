require_relative 'entity_base'

class Option < EntityBase
  def initialize(id, text, is_correct_answer)
    @text = text
    @is_correct_answer = is_correct_answer
    super(id)
  end

  def is_valid?
    if @text.nil? || @text.empty?
      return "Option text is required"
    end

    if @is_correct_answer.nil?
      return "Option text is required"
    end

    nil
  end

  def to_hash
    { "id" => @id, "text" => @text, "isCorrect" => @is_correct_answer }
  end

  def update_hash
    { "text" =>
        {'value' => @text, 'action' => 'PUT'},
      "isCorrect" =>
        { 'value' => @is_correct_answer, 'action' => 'PUT'} }
  end
end