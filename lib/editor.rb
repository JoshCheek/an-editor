class Editor
  HIDE_CURSOR = "\e[?25l"
  SHOW_CURSOR = "\e[?25h"

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
    self.running = false
    stdout.print SHOW_CURSOR
    self
  end

  def process
  end
end
