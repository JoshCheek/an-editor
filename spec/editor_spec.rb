require 'editor'
require 'spec_helper'

RSpec.describe 'Editor' do
  def editor_for(argv:[], inputs:[], stdout: TestHelpers::FakeOutstream.new)
    stdin  = TestHelpers::FakeInstream.new(inputs)
    Editor.new(argv: argv, stdout: stdout, stdin: stdin)
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
    it 'reads in one chunk of input and processes it' do
      editor = editor_for inputs: ["a", "b"]
      expect(editor.to_s).to eq "\n"
      expect(editor.process.stdin.remaining).to eq ["b"]
      expect(editor.to_s).to eq "a\n"
    end

    specify 'text gets appended to the buffer' do
      editor = editor_for inputs: ["a", "b", "c"]
      expect(editor.process.to_s).to eq "a\n"
      expect(editor.process.to_s).to eq "ab\n"
      expect(editor.process.to_s).to eq "abc\n"
    end

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
