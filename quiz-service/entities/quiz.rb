require_relative 'entity_base'

class Quiz < EntityBase
  attr_reader :id, :user_name, :questions, :quantity
  def initialize(id, user_name, status, quantity, grade, category)
    @user_name = user_name
    @grade = grade
    @quantity = quantity
    @status = status
    @category = category
    @questions = []
    super(id)
  end

  def is_valid?
    if @user_name.nil? || @user_name.empty?
      "Username is required"
    end
  end

  def set_questions(questions)
    @questions = questions
    self
  end

  def set_quantity
    unless questions.nil?
      @quantity = questions.length()
      self
    end
  end

  def set_grade(grade)
    if grade >= 0
      @grade = grade
    end
  end

  def set_status(status)
    if status.is_a? QuizStatus
      @status = status
    end
  end

  def to_hash
    base = self.to_h
    hash = {'UserName' => @user_name,
            'Quantity' => @quantity,
            'Status' => @status,
            'Grade' => @grade,
            'Category' => @category,
            'Question' => @questions }
    base.merge(hash)
  end

  def update_hash
    {
      'Grade' => { 'value' => @grade, 'action' => 'PUT'},
      'Status' => { 'value' => @status, 'action' => 'PUT'},
      'UpdatedDate' => { 'value' => @updated_date.to_s, 'action' => 'PUT'}
    }
  end
end

class QuizStatus
  UNKNOWN = -1
  ONGOING = 0
  FINISHED = 1
  ABANDONED = 2
end