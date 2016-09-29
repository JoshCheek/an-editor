class Editor
  module ANSI
    HIDE_CURSOR = "\e[?25l"
    SHOW_CURSOR = "\e[?25h"
    TOPLEFT     = "\e[H"
    CLEAR       = "\e[2J"
  end
end
