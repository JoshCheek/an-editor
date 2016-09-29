class State
  def new(*args)
    self.class.new(*args)
  end

  attr_accessor :lines, :y, :x
  def initialize(lines:[])
    self.lines = lines
    self.y     = 0
    self.x     = 0
  end

  def to_s
    lines.join("\n") << "\n"
  end

  def insert(input)
    new lines: previous_lines + [current_line << input] + remaining_lines
  end

  def previous_lines
    lines[0...y]
  end

  def current_line
    lines[y] || ""
  end

  def remaining_lines
    lines[y+1..-1] || []
  end
end


class Editor
  HIDE_CURSOR = "\e[?25l"
  SHOW_CURSOR = "\e[?25h"

  attr_accessor :argv, :stdin, :stdout, :running, :state

  alias running? running

  def initialize(argv:, stdin:, stdout:)
    self.argv    = argv
    self.stdin   = stdin
    self.stdout  = stdout
    self.running = false
    self.state   = State.new
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
    input = stdin.readpartial 1024
    self.state = state.insert input
    self
  end

  def to_s
    state.to_s
  end
end
