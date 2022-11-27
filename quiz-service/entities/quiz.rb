class Quiz < EntityBase
  def initialize(id, user_name, questions, grade)
    @user_name = user_name
    @questions = questions
    @grade = grade
    super(id)
  end

  def is_valid?
    if @user_name.nil? || @user_name.empty?
      "Username is required"
    end

    if @questions.nil?
      "Questions can't be null"
    end
  end

  def update_status(status)
    if status.is_a? QuizStatus
      @status = status
    end
  end
end

class QuizStatus
  ONGOING = 0
  FINISHED = 1
  ABANDONED = -1
end