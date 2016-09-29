require 'editor/state'

class Editor
  attr_reader :argv, :stdin, :stdout, :running, :state, :ansi

  alias running? running

  def initialize(argv:, stdin:, stdout:, lines:, x:, y:, ansi:)
    self.argv    = argv
    self.stdin   = stdin
    self.stdout  = stdout
    self.running = false
    self.state   = State.new(lines: lines, x: x, y: y)
    self.ansi    = ansi
  end

  def run
    self.running = true
    stdout.print ansi.hide_cursor
    self
  end

  def finish
    self.running = false
    stdout.print ansi.show_cursor
    self
  end

  def process
    stdout.print ansi.topleft, ansi.clear, state.to_s
    input = stdin.readpartial 1024
    case input
    when ?\C-d then self.running = false
    when ?\C-a then self.state = state.to_beginning_of_line
    when ?\C-e then self.state = state.to_end_of_line
    when ?\C-p, ansi.up_arrow   then self.state = state.cursor_up
    when ?\C-n, ansi.down_arrow then self.state = state.cursor_down
    when ?\C-b, ansi.left_arrow then self.state = state.cursor_left
    when ?\C-f, ansi.right_arrow then self.state = state.cursor_right
    else self.state = state.insert(input)
    end
    self
  end

  def to_s
    state.to_s
  end

  private

  attr_writer :argv, :stdin, :stdout, :running, :state, :ansi
end
