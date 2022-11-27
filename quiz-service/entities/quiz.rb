require_relative 'entity_base'

class Quiz < EntityBase
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
    hash = {'userName' => @user_name,
            'quantity' => @quantity,
            'status' => @status,
            'grade' => @grade,
            'category' => @category,
            'question' => @questions }
    base.merge(hash)
  end

  def update_hash
    {
      'grade' => { 'value' => @grade, 'action' => 'PUT'},
      'status' => { 'value' => @status, 'action' => 'PUT'},
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