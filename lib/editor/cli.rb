require 'editor'

class Editor
  class CLI
    attr_reader :argv, :stdin, :stdout, :running, :editor, :ansi, :undos, :redos

    alias running? running

    def initialize(argv:, stdin:, stdout:, lines:, x:, y:, ansi:)
      self.argv    = argv
      self.stdin   = stdin
      self.stdout  = stdout
      self.running = false
      self.editor   = Editor.new(lines: lines, x: x, y: y)
      self.ansi    = ansi
      self.undos   = []
      self.redos   = []
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
        self.editor = editor.to_beginning_of_line
      when ?\C-e
        self.editor = editor.to_end_of_line
      when ?\C-p, ansi.up_arrow
        self.editor = editor.cursor_up
      when ?\C-n, ansi.down_arrow
        self.editor = editor.cursor_down
      when ?\C-b, ansi.left_arrow
        self.editor = editor.cursor_left
      when ?\C-f, ansi.right_arrow
        self.editor = editor.cursor_right
      when ?\C-u
        undo!
      when ?\C-r
        redo!
      when ansi.meta_b
        self.editor = editor.back_word
      when ansi.meta_f
        self.editor = editor.forward_word
      when ansi.return
        save_undo
        self.editor = editor.return
      when ansi.backspace
        save_undo
        self.editor = editor.backspace
      else
        save_undo
        self.editor = editor.insert(input)
      end
      self
    end

    def render
      stdout.print ansi.topleft, ansi.clear
      if editor.empty?
        stdout.print "#{ansi.bg_blue} #{ansi.bg_off}\r\n"
      end
      editor.each_line do |line, cursor|
        if cursor
          line = line[0...cursor] + "#{ansi.bg_blue}#{line[cursor]||" "}#{ansi.bg_off}" + (line[cursor+1..-1]||"")
        end
        stdout.print line, "\r\n"
      end
    end

    def to_s
      editor.to_s
    end

    private

    attr_writer :argv, :stdin, :stdout, :running, :editor, :ansi, :undos, :redos

    def save_undo
      undos << editor
    end

    def undo!
      return unless undos.any?
      redos.push editor
      self.editor = undos.pop
    end

    def redo!
      return unless redos.any?
      undos.push editor
      self.editor = redos.pop
    end
  end
end
