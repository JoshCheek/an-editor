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

module TestHelpers
  class FakeInstream
  end
end
