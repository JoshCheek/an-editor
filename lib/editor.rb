class Editor
  attr_accessor :argv, :stdin, :stdout

  def initialize(argv:, stdin:, stdout:)
    self.argv   = argv
    self.stdin  = stdin
    self.stdout = stdout
  end

  def run
  end

  def running?
    false
  end

  def finish
  end

  def process
  end
end
