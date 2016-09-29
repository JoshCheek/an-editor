require 'editor'

RSpec.describe 'Editor' do
  describe 'after initialization' do
    it 'is not running'
    it 'knows its argv, stdin, stdout'
  end

  describe 'run' do
    it 'sets the editor to running state'
    it 'turns off dislay of the cursor'
  end

  describe 'finish' do
    it 'sets the editor to not running state'
    it 'turns on dislay of the cursor'
  end

  describe 'running?' do
    it 'reports the running status'
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
