class QuizService
  def initialize(logger, quiz_repository)
    @logger = logger
    @quiz_repository = quiz_repository
  end

  def find_by_id(id)
    if id.nil?
      ServiceResponse.fail("id param can't be null")
    end
    quiz = @quiz_repository.find_by_id(id)
  end

  def create(query)
    unless query.is_valid?
    end
  end
end