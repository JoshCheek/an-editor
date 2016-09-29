class State
  attr_accessor :lines, :y, :x, :kill_ring

  def initialize(lines: [], y:0, x:0)
    self.lines     = lines
    self.y         = y
    self.x         = x
    self.kill_ring = []
  end

  def each_line(&block)
    lines.each_with_index do |line, crnt_y|
      cursor = nil
      cursor = x if crnt_y == y
      block.call line, cursor
    end
  end

  def delete_word
    loop do
      break if x == 0
      break if current_line[x-1] =~ /\S/
      delete
    end
    loop do
      break if x == 0
      break if current_line[x-1] =~ /\s/
      delete
    end
  end

  def back_word
    loop do
      left
      break if x == 0
      break if at_cursor =~ /\s/
    end
    loop do
      left
      break if x == 0
      break if at_cursor =~ /\S/
    end
  end

  def forward_word
    loop do
      right
      break if x == current_line.length
      break if at_cursor =~ /\s/
    end
    loop do
      right
      break if x == current_line.length
      break if at_cursor =~ /\S/
    end
  end

  def kill_to_end
    self.kill_ring << (at_cursor + post_cursor)
    self.current_line = pre_cursor
  end

  def kill_to_beginning
    self.kill_ring << pre_cursor
    self.current_line = at_cursor + post_cursor
    self.x = 0
  end

  def yank
    insert kill_ring[-1]
  end

  def delete
    if x == 0 && y == 0
      # noop
    elsif x == 0
      self.y -= 1
      self.x = current_line.length
      self.current_line += next_line
      self.lines = lines[0..y] + lines[y+2..-1]
    else
      self.x -= 1
      self.current_line = pre_cursor + post_cursor
    end
  end

  def next_line
    lines[y+1] || ""
  end

  def at_cursor
    current_line[x] || ""
  end

  def pre_cursor
    current_line[0...x]   || ""
  end

  def post_cursor
    current_line[x+1..-1] || ""
  end

  def insert(string)
    self.current_line = current_line[0...x] + string + current_line[x..-1]
    self.x += string.length
    bound_cursor
  end

  def current_line=(line)
    lines[y] = line
    bound_cursor
  end

  def current_line
    lines[y] || ""
  end

  def return
    next_line = at_cursor + post_cursor
    self.current_line = pre_cursor
    self.lines = lines[0..y] + [next_line] + lines[y+1..-1]
    down
    to_beginning_of_line
  end

  def up
    self.y -= 1
    bound_cursor
  end

  def down
    self.y += 1
    bound_cursor
  end

  def left
    self.x -= 1
    bound_cursor
  end

  def right
    self.x += 1
    bound_cursor
  end

  def to_beginning_of_line
    self.x = 0
    bound_cursor
  end

  def to_end_of_line
    self.x = current_line.length
    bound_cursor
  end

  def bound_cursor
    self.y = [0, y].max
    self.y = [lines.length-1, y].min

    self.x = [0, x].max
    self.x = [current_line.length, x].min
  end
end

class Editor
  attr_accessor :argv, :stdin, :stdout, :state, :running, :filename

  alias running? running

  def initialize(argv:, stdin:, stdout:)
    self.argv     = argv
    self.filename = argv.first || "file"
    self.stdin    = stdin
    self.stdout   = stdout
    self.running  = false
    self.state    = State.new
  end

  def run
    self.running = true
    if File.exist? filename
      state.lines = File.read(filename).lines.map(&:chomp)
    end
    stdout.print "\e[?25l"
  end

  def finish
    self.running = false
    stdout.print "\e[?25h"
  end

  def process
    render
    input = read_input
    case input
    when "\e[A", ?\C-p  then state.up
    when "\e[B", ?\C-n  then state.down
    when "\e[C", ?\C-f  then state.right
    when "\e[D", ?\C-b  then state.left
    when "\e"           then self.running = false
    when "\r"           then state.return
    when "\u007F"       then state.delete
    when "\e\u007F"     then state.delete_word
    when ?\C-a          then state.to_beginning_of_line
    when ?\C-e          then state.to_end_of_line
    when ?\C-k          then state.kill_to_end
    when ?\C-u          then state.kill_to_beginning
    when ?\C-y          then state.yank
    when ?\C-s          then save_buffer
    when "\ef"          then state.forward_word
    when "\eb"          then state.back_word
    else state.insert input
    end
  end

  def save_buffer
    text = state.lines.join("\n") << "\n"
    File.write filename, text
  end

  def read_input
    stdin.readpartial 1024
  end

  def render
    stdout.print "\e[H\e[2J"
    state.each_line do |line, cursor|
      if !cursor
        stdout.print line, "\r\n"
      else
        line = line.dup
        if line.length <= cursor
          line << "\e[44m \e[49m"
        else
          line[cursor] = "\e[44m#{line[cursor]}\e[49m"
        end
        stdout.print line, "\r\n"
      end
    end
  end
end
