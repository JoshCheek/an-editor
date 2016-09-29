require 'editor/state'
require 'editor/ansi'

class Editor
  attr_reader :argv, :stdin, :stdout, :running, :state

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
    stdout.print ANSI::HIDE_CURSOR
    self
  end

  def finish
    self.running = false
    stdout.print ANSI::SHOW_CURSOR
    self
  end

  def process
    stdout.print ANSI::TOPLEFT, ANSI::CLEAR, state.to_s
    input = stdin.readpartial 1024
    case input
    when ?\C-d then self.running = false
    when ?\C-a then self.state = state.to_beginning_of_line
    when ?\C-e then self.state = state.to_end_of_line
    else self.state = state.insert(input)
    end
    self
  end

  def to_s
    state.to_s
  end

  private

  attr_writer :argv, :stdin, :stdout, :running, :state
end
