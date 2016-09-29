require 'editor'

module TestHelpers
  class FakeOutstream
    def initialize
      self.printeds = []
    end

    def has_printed?(str)
      printeds.any? { |printed| printed.include? str }
    end

    def print(str)
      printeds << str
      nil
    end

    private

    attr_accessor :printeds
  end
end

RSpec.describe 'Editor' do
  def editor
    argv   = []
    stdout = TestHelpers::FakeOutstream.new
    stdin  = 'fake stdin'
    Editor.new(argv: argv, stdout: stdout, stdin: stdin)
  end

  describe 'after initialization' do
    it 'is not running' do
      expect(editor).to_not be_running
    end
    it 'knows its argv, stdin, stdout' do
      argv   = ['a', 'b']
      stdin  = 'fake stdin'
      stdout = 'fake stdout'
      editor =  Editor.new(argv: argv, stdout: stdout, stdin: stdin)
      expect(editor.argv).to eq argv
      expect(editor.stdin).to eq stdin
      expect(editor.stdout).to eq stdout
    end
  end

  describe 'run' do
    it 'sets the editor to running state' do
      e = editor
      expect(e).to_not be_running
      e.run
      expect(e).to be_running
    end
    it 'turns off dislay of the cursor' do
      e = editor
      expect(e.stdout).to_not have_printed "\e[?25l"
      e.run
      expect(e.stdout).to have_printed "\e[?25l"
    end
  end

  describe 'finish' do
    it 'sets the editor to not running state' do
      e = editor.run
      expect(e).to be_running
      e.finish
      expect(e).to_not be_running
    end

    it 'turns on dislay of the cursor' do
      e = editor.run
      expect(e.stdout).to_not have_printed "\e[?25h"
      e.finish
      expect(e.stdout).to have_printed "\e[?25h"
    end
  end

  describe 'running?' do
    it 'reports the running status' do
      e = editor
      expect(e).to_not be_running
      e.run
      expect(e).to be_running
      e.finish
      expect(e).to_not be_running
    end
  end

  describe 'process' do
    it 'reads in one chunk of input and processes it'
    specify 'text gets appended to the buffer'
    specify 'C-a goes to the beginning of the line'
    specify 'C-e goes to the end of the line'

    describe 'up arrow / C-p' do
      it 'goes up one line'
      it 'does not go up from the first line'
    end

    describe 'down arrow / C-n' do
      it 'goes down one line'
      it 'does not go down from the last line'
    end

    describe 'left arrow / C-b' do
      it 'goes left one character'
      it 'does not go left from the first character'
    end

    describe 'right arrow / C-f' do
      it 'goes right one character'
      it 'does not go right from one-past the last character'
    end

    describe 'escape' do
      it 'quits the program'
    end

    describe 'return' do
      it 'adds a line to the end of the buffer when it is at the end of the document'
      it 'inserts an empty line when it\'s at the end of a line'
      it 'breaks a line at the cursor when it\'s in the middle of a line'
    end

    describe 'delete' do
      it 'deletes the character before the cursor'
      it 'joins the current line to the previous line when it\'s at the beginning of the line'
      it 'does nothing at the beginning of document'
    end

    # M-b, M-f, M-delete, C-k, C-u, C-y
  end
end
