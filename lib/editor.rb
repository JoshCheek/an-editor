class State
  def new(args)
    args = {lines: lines, y: y, x: x}.merge(args)
    self.class.new(args)
  end

  attr_accessor :lines, :y, :x
  def initialize(lines:, x:, y:)
    self.lines = lines
    self.x     = x
    self.y     = y
  end

  def to_s
    lines.join("\n") << "\n"
  end

  def insert(input)
    line = self.crnt_line.dup
    line[x, 0] = input
    x = self.x + input.length
    new x: x, lines: prev_line + [line] + rem_lines
  end

  def prev_line
    lines[0...y]
  end

  def crnt_line
    lines[y] || ""
  end

  def rem_lines
    lines[y+1..-1] || []
  end

  def to_beginning_of_line
    new x: 0
  end

  def to_end_of_line
    new x: crnt_line.length
  end
end


class Editor
  ANSI_HIDE_CURSOR = "\e[?25l"
  ANSI_SHOW_CURSOR = "\e[?25h"
  ANSI_TOPLEFT     = "\e[H"
  ANSI_CLEAR       = "\e[2J"

  attr_accessor :argv, :stdin, :stdout, :running, :state

  alias running? running

  def initialize(argv:, stdin:, stdout:, lines:, x:, y:)
    self.argv    = argv
    self.stdin   = stdin
    self.stdout  = stdout
    self.running = false
    self.state   = State.new(lines: lines, x: x, y: y)
  end

  def run
    self.running = true
    stdout.print ANSI_HIDE_CURSOR
    self
  end

  def finish
    self.running = false
    stdout.print ANSI_SHOW_CURSOR
    self
  end

  def process
    stdout.print ANSI_TOPLEFT, ANSI_CLEAR, state.to_s
    input = stdin.readpartial 1024
    self.state = case input
    when ?\C-a then state.to_beginning_of_line
    when ?\C-e then state.to_end_of_line
    else state.insert input
    end
    self
  end

  def to_s
    state.to_s
  end
end
