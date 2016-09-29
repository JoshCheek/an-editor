class Editor
  class ANSI
    def hide_cursor
      "\e[?25l"
    end

    def show_cursor
      "\e[?25h"
    end

    def topleft
      "\e[H"
    end

    def clear
      "\e[2J"
    end

    def up_arrow
      "\e[A"
    end

    def down_arrow
      "\e[B"
    end
  end
end
