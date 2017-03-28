class User
  attr_reader :id

  def initialize(id)
    @id = id
    @commands = []
    @engaged = false
    @greeted = false
  end

  def current_command
    @commands.last
  end

  def set_command(command)
    @commands << command
  end

  def reset_command
    @commands = []
  end

  def engage
    @engaged = true
  end

  def disengage
    @engaged = false
  end

  def engaged?
    @engaged
  end

  def greet
    @greeted = true
  end

  def greeted?
    @greeted
  end

end
