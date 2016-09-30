class Editor
  class ANSI
    def escape
      "\e"
    end

    def return
      "\r"
    end

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

    def right_arrow
      "\e[C"
    end

    def left_arrow
      "\e[D"
    end

    def bg_blue
      "\e[44m"
    end

    def bg_off
      "\e[49m"
    end
  end
end
