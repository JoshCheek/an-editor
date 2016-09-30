require 'editor/cli'
require 'editor/ansi'
require 'spec_helper'

RSpec.describe 'Editor::CLI' do
  def editor_for(lines:[], x: 0, y: 0, argv:[], inputs:[], stdout: TestHelpers::FakeOutstream.new, ansi: Editor::ANSI.new)
    stdin  = TestHelpers::FakeInstream.new(inputs)
    Editor::CLI.new(lines: lines, x: x, y: y, argv: argv, stdout: stdout, stdin: stdin, ansi: ansi)
  end

  def new_editor
    editor_for({})
  end

  def editor
    @editor ||= new_editor
  end

  describe 'after initialization' do
    it 'is not running' do
      expect(editor).to_not be_running
    end
    it 'knows its argv, stdin, stdout' do
      editor =  editor_for argv: ['a', 'b'], inputs: ['fake stdin'], stdout: 'fake stdout'
      expect(editor.argv).to eq ['a', 'b']
      expect(editor.stdin.readpartial(1000)).to eq 'fake stdin'
      expect(editor.stdout).to eq 'fake stdout'
    end
  end

  describe 'run' do
    it 'sets the editor to running state' do
      expect(editor).to_not be_running
      editor.run
      expect(editor).to be_running
    end
    it 'turns off dislay of the cursor' do
      expect(editor.stdout).to_not have_printed "\e[?25l"
      editor.run
      expect(editor.stdout).to have_printed "\e[?25l"
    end
  end

  describe 'finish' do
    it 'sets the editor to not running state' do
      editor.run
      expect(editor).to be_running
      editor.finish
      expect(editor).to_not be_running
    end

    it 'turns on dislay of the cursor' do
      expect(editor.stdout).to_not have_printed "\e[?25h"
      editor.finish
      expect(editor.stdout).to have_printed "\e[?25h"
    end
  end

  describe 'running?' do
    it 'reports the running status' do
      expect(editor).to_not be_running
      editor.run
      expect(editor).to be_running
      editor.finish
      expect(editor).to_not be_running
    end
  end

  describe 'process' do
    it 'clears the screen and prints the current buffer with the cursor' do
      editor = editor_for inputs: ["a", "b", "c"]
      expect(editor.stdout.printed).to eq ""
      expect(editor.process.stdout.printed).to eq "\e[H\e[2J\e[44m \e[49m\r\n"
      expect(editor.process.stdout.printed).to eq "\e[H\e[2J\e[44m \e[49m\r\n" "\e[H\e[2Ja\e[44m \e[49m\r\n"
      expect(editor.process.stdout.printed).to eq "\e[H\e[2J\e[44m \e[49m\r\n" "\e[H\e[2Ja\e[44m \e[49m\r\n" "\e[H\e[2Jab\e[44m \e[49m\r\n"
    end

    it 'reads in one chunk of input and processes it' do
      editor = editor_for inputs: ["a", "b"]
      expect(editor.to_s).to eq "\r\n"
      expect(editor.process.stdin.remaining).to eq ["b"]
      expect(editor.to_s).to eq "a\r\n"
    end

    specify 'text gets appended to the buffer' do
      editor = editor_for inputs: ["a", "b", "c"]
      expect(editor.process.to_s).to eq "a\r\n"
      expect(editor.process.to_s).to eq "ab\r\n"
      expect(editor.process.to_s).to eq "abc\r\n"
    end

    specify 'C-d and esc set it to not running' do
      editor = editor_for inputs: [?\C-d, "a"]
      editor.run
      expect(editor).to be_running
      expect(editor.process).to_not be_running
      expect(editor.to_s).to eq "\r\n"

      editor = editor_for inputs: ["\e", "a"]
      editor.run
      expect(editor).to be_running
      expect(editor.process).to_not be_running
      expect(editor.to_s).to eq "\r\n"
    end

    specify 'C-a goes to the beginning of the line' do
      expect(editor_for(inputs: ["!"], lines: ["abcd"], x: 2).process.to_s)
        .to eq "ab!cd\r\n"

      expect(editor_for(inputs: [?\C-a, "!"], lines: ["abcd"], x: 2).process.process.to_s)
        .to eq "!abcd\r\n"
    end

    specify 'C-e goes to the end of the line' do
      expect(editor_for(inputs: ["!"], lines: ["abcd"], x: 2).process.to_s)
        .to eq "ab!cd\r\n"

      expect(editor_for(inputs: [?\C-e, "!"], lines: ["abcd"], x: 2).process.process.to_s)
        .to eq "abcd!\r\n"
    end

    context 'when it sets the cursor to an invalid location it corrects it' do
      specify 'past the last line gets set to the last line' do
        expect(Editor.new(lines: ["abc", "def"], y: 0).y).to eq 0
        expect(Editor.new(lines: ["abc", "def"], y: 1).y).to eq 1
        expect(Editor.new(lines: ["abc", "def"], y: 2).y).to eq 1
      end

      specify 'past the last character on the line gets set to 1 past' do
        expect(Editor.new(lines: ["abc"], x: 2).x).to eq 2
        expect(Editor.new(lines: ["abc"], x: 3).x).to eq 3
        expect(Editor.new(lines: ["abc"], x: 4).x).to eq 3
      end

      specify 'before the first line gets set to the first line' do
        expect(Editor.new(lines: ["abc", "def"], y: -1).y).to eq 0
        expect(Editor.new(lines: ["abc", "def"], y: 0).y).to eq 0
        expect(Editor.new(lines: ["abc", "def"], y: 1).y).to eq 1
      end

      specify 'before the first character on the line gets set to the first char' do
        expect(Editor.new(lines: ["abc"], x: -1).x).to eq 0
        expect(Editor.new(lines: ["abc"], x: 0).x).to eq 0
        expect(Editor.new(lines: ["abc"], x: 1).x).to eq 1
      end
    end

    describe 'up arrow / C-p' do
      def test_up(inputs, output, y:)
        editor = editor_for(inputs: inputs, lines: ["abcd", "efgh"], x: 2, y: y)
        inputs.each { editor.process }
        expect(editor.to_s).to eq output
      end

      it 'goes up one line' do
        test_up ["!"],         "abcd\r\nef!gh\r\n", y: 1
        test_up [?\C-p, "!"],  "ab!cd\r\nefgh\r\n", y: 1

        test_up ["!"],         "abcd\r\nef!gh\r\n", y: 1
        test_up ["\e[A", "!"], "ab!cd\r\nefgh\r\n", y: 1
      end

      it 'does not go up from the first line' do
        test_up [?\C-p,  "!"], "ab!cd\r\nefgh\r\n", y: 0
        test_up ["\e[A", "!"], "ab!cd\r\nefgh\r\n", y: 0
      end
    end

    describe 'down arrow / C-n' do
      def test_down(inputs, output, y:)
        editor = editor_for(inputs: inputs, lines: ["abcd", "efgh"], x: 2, y: y)
        inputs.each { editor.process }
        expect(editor.to_s).to eq output
      end

      it 'goes down one line' do
        test_down ["!"],         "ab!cd\r\nefgh\r\n", y: 0
        test_down [?\C-n, "!"],  "abcd\r\nef!gh\r\n", y: 0

        test_down ["!"],         "ab!cd\r\nefgh\r\n", y: 0
        test_down ["\e[B", "!"], "abcd\r\nef!gh\r\n", y: 0
      end

      it 'does not go down from the last line' do
        test_down [?\C-n,  "!"], "abcd\r\nef!gh\r\n", y: 1
        test_down ["\e[B", "!"], "abcd\r\nef!gh\r\n", y: 1
      end
    end

    describe 'right arrow / C-f' do
      def test_right(inputs, output, x:)
        editor = editor_for(inputs: inputs, lines: ["abcd"], x: x, y: 0)
        inputs.each { editor.process }
        expect(editor.to_s).to eq output
      end

      it 'goes right one character' do
        test_right ["!"],         "ab!cd\r\n", x: 2
        test_right [?\C-f, "!"],  "abc!d\r\n", x: 2

        test_right ["!"],         "ab!cd\r\n", x: 2
        test_right ["\e[C", "!"], "abc!d\r\n", x: 2
      end

      it 'does not go right from one-past the last character' do
        test_right [?\C-f,  "!"], "abcd!\r\n", x: 4
        test_right ["\e[C", "!"], "abcd!\r\n", x: 4
      end
    end

    describe 'left arrow / C-b' do
      def test_left(inputs, output, x:)
        editor = editor_for(inputs: inputs, lines: ["abcd"], x: x, y: 0)
        inputs.each { editor.process }
        expect(editor.to_s).to eq output
      end

      it 'goes left one character' do
        test_left ["!"],         "ab!cd\r\n", x: 2
        test_left [?\C-b, "!"],  "a!bcd\r\n", x: 2

        test_left ["!"],         "ab!cd\r\n", x: 2
        test_left ["\e[D", "!"], "a!bcd\r\n", x: 2
      end

      it 'does not go left from the first character' do
        test_left [?\C-b,  "!"], "!abcd\r\n", x: 0
        test_left ["\e[D", "!"], "!abcd\r\n", x: 0
      end
    end

    describe 'return' do
      it 'adds a line to the end of the buffer when it is at the end of the document' do
        editor = editor_for(lines:["abc", "def"], x: 3, y: 1, inputs:["\r", "A"])
        expect(editor.process.process.to_s).to eq "abc\r\ndef\r\nA\r\n"
      end

      it 'inserts an empty line when it\'s at the end of a line' do
        editor = editor_for(lines:["abc", "def"], x: 3, y: 0, inputs:["\r", "A"])
        expect(editor.process.process.to_s).to eq "abc\r\nA\r\ndef\r\n"
      end

      it 'breaks a line at the cursor when it\'s in the middle of a line' do
        editor = editor_for(lines:["abc", "def"], x: 1, y: 0, inputs:["\r", "A"])
        expect(editor.process.process.to_s).to eq "a\r\nAbc\r\ndef\r\n"
      end
    end

    describe 'delete' do
      it 'deletes the character before the cursor' do
        expect(editor_for(lines:["abc"], x: 2, inputs:["\u007F", "B"]).process.process.to_s)
          .to eq "aBc\r\n"
      end

      it 'joins the current line to the previous line when it\'s at the beginning of the line' do
        expect(editor_for(lines:["abc", "def"], y: 1, x: 0, inputs:["\u007F", "B"]).process.process.to_s)
          .to eq "abcBdef\r\n"
      end

      it 'does nothing at the beginning of document' do
        expect(editor_for(lines:["abc"], y: 0, x: 0, inputs:["\u007F", "B"]).process.process.to_s)
          .to eq "Babc\r\n"
      end
    end

    # M-b, M-f, M-delete, C-k, C-u, C-y
  end
end
