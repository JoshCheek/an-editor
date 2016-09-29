module TestHelpers
  class FakeOutstream
    def initialize
      self.printeds = []
    end

    def has_printed?(str)
      printeds.any? { |printed| printed.include? str }
    end

    def print(*strs)
      printeds.concat(strs)
      nil
    end

    def printed
      printeds.join
    end

    private

    attr_accessor :printeds
  end
end

module TestHelpers
  class FakeInstream
    attr_accessor :remaining, :inputs

    def initialize(to_read)
      self.inputs    = to_read
      self.remaining = to_read.dup
    end

    def readpartial(length)
      read = remaining.shift
      if !read
        raise("No more input!")
      elsif length < read.length
        raise "Tried to read #{length} chars, but the input had #{read.length} chars"
      end
      read
    end
  end
end
