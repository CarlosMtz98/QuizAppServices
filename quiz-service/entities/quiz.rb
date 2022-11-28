require_relative 'entity_base'

class Quiz < EntityBase
  attr_reader :id, :user_name, :questions, :quantity, :answers, :grade
  def initialize(id, user_name, status, quantity, grade, category, questions, answers)
    @user_name = user_name
    @grade = grade
    @quantity = quantity
    @status = status
    @category = category
    @questions = questions.nil? ? [] : questions
    @answers = answers.nil? ? [] : answers
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
      @quantity = questions.length
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

  def reset_quiz
    @status = QuizStatus::ONGOING
    @grade = 0
    @answers = []
  end

  def add_answer(answer)
    @answers << answer
  end

  def to_hash
    base = self.to_h
    hash = {'userName' => @user_name,
            'quantity' => @quantity,
            'status' => @status,
            'grade' => @grade,
            'category' => @category,
            'questions' => @questions,
            'answers' => @answers.map { |ans| ans.to_hash} }
    base.merge(hash)
  end

  def finish
    correct_answers = @answers.count { |ans| ans.is_correct }
    questions_length = @questions.length
    if correct_answers > 0 && questions_length > 0
      @grade = (correct_answers.to_f / questions_length.to_f) * 100
    end
    @status = QuizStatus::FINISHED
    self
  end

  def update_hash
    {
      'grade' => { 'value' => @grade, 'action' => 'PUT'},
      'status' => { 'value' => @status, 'action' => 'PUT'},
      'updatedDate' => { 'value' => @updated_date.to_s, 'action' => 'PUT'}
    }
  end
end

class QuizStatus
  UNKNOWN = 'unknown'
  ONGOING = 'ongoing'
  FINISHED = 'finished'
  ABANDONED = 'abandoned'
end