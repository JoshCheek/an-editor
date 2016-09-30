class Editor
  class State
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
      lines.join("\n") << "\n"
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
  end
end
