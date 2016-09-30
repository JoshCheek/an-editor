class Editor
  def new(args)
    args = {lines: lines, y: y, x: x}.merge(args)
    self.class.new(args)
  end

  attr_accessor :lines, :y, :x
  def initialize(lines:[], x:0, y:0)
    self.lines = lines
    self.y     = [0, [lines.length-1,   y].min].max
    self.x     = [0, [crnt_line.length, x].min].max
  end

  def to_s
    lines.join("\r\n") << "\r\n"
  end

  def insert(input)
    line = self.crnt_line.dup
    line[x, 0] = input
    x = self.x + input.length
    new x: x, lines: prev_lines + [line] + rem_lines
  end

  def prev_lines
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

  def cursor_up
    new y: y-1
  end

  def cursor_down
    new y: y+1
  end

  def cursor_left
    new x: x-1
  end

  def cursor_right
    new x: x+1
  end

  def backspace
    if at_bol? && y == 0
      self
    elsif at_bol?
      lines = prev_lines
      lines[-1] = (lines.last||"") + crnt_line
      lines += rem_lines
      cursor_up.to_end_of_line.new(lines: lines)
    else
      new(x: x-1).delete
    end
  end

  def delete
    line = pre_cursor + post_cursor
    new lines: prev_lines + [line] + rem_lines
  end

  def return
    if at_eol?
      crnt_lines = [crnt_line, ""]
    else
      crnt_lines = [pre_cursor, at_cursor + post_cursor]
    end
    new x: 0, y: y+1, lines: prev_lines + crnt_lines + rem_lines
  end

  def pre_cursor
    crnt_line[0...x]
  end

  def post_cursor
    crnt_line[x+1..-1]
  end

  def at_cursor
    crnt_line[x]
  end

  def at_eol?
    x == crnt_line.length
  end

  def at_bol?
    x == 0
  end

  def each_line(&block)
    lines.each_with_index do |line, index|
      cursor = nil
      cursor = x if index == y
      block.call line, cursor
    end
  end

  def empty?
    lines.empty?
  end

  def back_word
    x = self.x
    x -= 1 if at_eol?
    x -= 1 if at_beginning_of_word?
    x -= 1 while char_at(y, x) =~ /\s/
    x -= 1 while char_at(y, x) =~ /\w/
    x += 1
    new(x: x)
  end

  def forward_word
    x = self.x
    x += 1 while char_at(y, x) =~ /\s/
    x += 1 while char_at(y, x) =~ /\w/
    new(x: x)
  end

  def char_at(y, x)
    (lines[y] || "")[x] || ""
  end

  def at_beginning_of_word?
    char_at(y, x) =~ /\w/ && (at_bol? || char_at(y, x-1) =~ /\s/)
  end
end
