class Editor
  HIDE_CURSOR = "\e[?25l"

  attr_accessor :argv, :stdin, :stdout, :running

  alias running? running

  def initialize(argv:, stdin:, stdout:)
    self.argv    = argv
    self.stdin   = stdin
    self.stdout  = stdout
    self.running = false
  end

  def run
    self.running = true
    stdout.print HIDE_CURSOR
    self
  end

  def finish
  end

  def process
  end
end
