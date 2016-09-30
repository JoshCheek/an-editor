require 'editor'

class Editor
  class CLI
    attr_reader :argv, :stdin, :stdout, :running, :state, :ansi

    alias running? running

    def initialize(argv:, stdin:, stdout:, lines:, x:, y:, ansi:)
      self.argv    = argv
      self.stdin   = stdin
      self.stdout  = stdout
      self.running = false
      self.state   = Editor.new(lines: lines, x: x, y: y)
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
      render
      input = stdin.readpartial 1024
      case input
      when ?\C-d, ansi.escape
        self.running = false
      when ?\C-a
        self.state = state.to_beginning_of_line
      when ?\C-e
        self.state = state.to_end_of_line
      when ?\C-p, ansi.up_arrow
        self.state = state.cursor_up
      when ?\C-n, ansi.down_arrow
        self.state = state.cursor_down
      when ?\C-b, ansi.left_arrow
        self.state = state.cursor_left
      when ?\C-f, ansi.right_arrow
        self.state = state.cursor_right
      when ansi.return
        self.state = state.return
      when ansi.backspace
        self.state = state.backspace
      when ansi.meta_b
        self.state = state.back_word
      when ansi.meta_f
        self.state = state.forward_word
      else
        self.state = state.insert(input)
      end
      self
    end

    def render
      stdout.print ansi.topleft, ansi.clear
      if state.empty?
        stdout.print "#{ansi.bg_blue} #{ansi.bg_off}\r\n"
      end
      state.each_line do |line, cursor|
        if cursor
          line = line[0...cursor] + "#{ansi.bg_blue}#{line[cursor]||" "}#{ansi.bg_off}" + (line[cursor+1..-1]||"")
        end
        stdout.print line, "\r\n"
      end
    end

    def to_s
      state.to_s
    end

    private

    attr_writer :argv, :stdin, :stdout, :running, :state, :ansi
  end
end
