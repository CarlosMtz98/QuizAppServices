class Answer < EntityBase
  attr_reader :is_correct

  def initialize(id, is_correct, correct_answer, question_id)
    @is_correct = is_correct
    @correct_answer = correct_answer
    @question_id = question_id
    super(id)
  end

  def to_hash
    base = self.to_h
    hash = {'isCorrect' => @is_correct,
            'correctAnswer' => @correct_answer,
            'questionId' => @question_id }
    base.merge(hash)
  end

  def update_hash
    {
      'isCorrect' => { 'value' => @is_correct, 'action' => 'PUT'},
      'correctAnswer' => { 'value' => @correct_answer, 'action' => 'PUT'},
      'updatedDate' => { 'value' => @updated_date, 'action' => 'PUT'},
      'questionId' => { 'value' => @question_id, 'action' => 'PUT' }
    }
  end

end