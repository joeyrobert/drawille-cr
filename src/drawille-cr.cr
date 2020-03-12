require "colorize"

module Drawille
  PIXEL_MAP = [
    {0x01, 0x08},
    {0x02, 0x10},
    {0x04, 0x20},
    {0x40, 0x80},
  ]
  BRAILLE_CHAR_OFFSET = 0x2800
  NEW_LINE            = '\n'
  TERMINAL_LINES      = `tput lines`.to_i
  TERMINAL_COLUMNS    = `tput cols`.to_i
  VIEWPORT_HEIGHT     = TERMINAL_LINES * 4
  VIEWPORT_WIDTH      = TERMINAL_COLUMNS * 2
  SCREEN_CLEAR        = "\e[2J\e[1;1H"
  SCREEN_START        = "\e[0;0H"
  MASK                = 0b11111111
  WHITE               = {255_u8, 255_u8, 255_u8}

  alias RGB = Tuple(UInt8, UInt8, UInt8)

  class Canvas
    property terminal_lines : Int32
    property terminal_columns : Int32
    property viewport_height : Int32
    property viewport_width : Int32
    property viewport_area : Int32

    def initialize(@terminal_lines = TERMINAL_LINES, @terminal_columns = TERMINAL_COLUMNS)
      @viewport_height = @terminal_lines * 4
      @viewport_width = @terminal_columns * 2
      @viewport_area = @viewport_width * @viewport_height
      @viewport = Hash(Int32, RGB).new(WHITE)
    end

    def clear
      @viewport = Hash(Int32, RGB).new(WHITE)
    end

    def set(x : Int, y : Int, color : RGB = WHITE)
      pos = get_pos(x, y)
      if pos < @viewport_area
        @viewport[get_pos(x, y)] = color
      end
    end

    def unset(x : Int, y : Int)
      @viewport.delete(get_pos(x, y))
    end

    def toggle(x : Int, y : Int)
      col, row = get_pos(x, y)
      get(x, y) ? unset(x, y) : set(x, y)
    end

    def get(x : Int, y : Int) : Bool
      @viewport.has_key?(get_pos(x, y))
    end

    def get_pos(x : Int, y : Int) : Int
      x + y * @terminal_columns * 2
    end

    def render
      String.build do |str|
        (0...@terminal_lines).each do |row|
          y = 4 * row
          (0...@terminal_columns).each do |col|
            x = 2 * col
            value = BRAILLE_CHAR_OFFSET
            count = 0
            r = 0
            g = 0
            b = 0

            (0...2).each do |x_offset|
              (0...4).each do |y_offset|
                pos = get_pos(x + x_offset, y + y_offset)
                if @viewport[pos]?
                  value += PIXEL_MAP[y_offset][x_offset]
                  count += 1
                  color_value = @viewport[pos]
                  r += color_value[0]
                  g += color_value[1]
                  b += color_value[2]
                end
              end
            end

            # Average the colors
            if count > 0
              r = ((r / count).to_i32 & MASK).to_u8
              g = ((g / count).to_i32 & MASK).to_u8
              b = ((b / count).to_i32 & MASK).to_u8
              str << (value.chr).colorize(Colorize::ColorRGB.new(r, g, b))
            else
              str << ' '
            end
          end
        end
      end
    end

    def animate(fps = 20, &block)
      start = Time.monotonic
      frame = 0

      loop do
        elapsed = Time.measure do
          yield frame, Time.monotonic - start
          print SCREEN_START
          print render
        end
        amount_to_sleep = Math.max(1 / fps - elapsed.total_seconds, 0)
        sleep amount_to_sleep
        frame += 1
      end
    end
  end
end
