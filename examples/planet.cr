# Rotating planet renderer for the Terminal
# As described from https://gamedev.stackexchange.com/a/147216
require "stumpy_jpeg"
require "colorize"
require "option_parser"
require "../drawille"

SCALE_COEFF = 0.8
DISK_SIZE   = (Math.min(VIEWPORT_WIDTH, VIEWPORT_HEIGHT) * SCALE_COEFF).to_i32
DISK_LEFT   = (VIEWPORT_WIDTH - DISK_SIZE) // 2
DISK_TOP    = (VIEWPORT_HEIGHT - DISK_SIZE) // 2
DISK_RIGHT  = DISK_LEFT + DISK_SIZE
DISK_BOTTOM = DISK_TOP + DISK_SIZE

def run_animation(planet, speed)
  c = DrawilleCanvas.new
  planet = StumpyJPEG.read("examples/textures/#{planet}.jpg")
  planet_height = planet.height
  frame = 0

  loop do
    start = Time.utc
    c.clear
    (DISK_LEFT...DISK_RIGHT).each do |x|
      (DISK_TOP...DISK_BOTTOM).each do |y|
        px = ((x - DISK_LEFT) * 2) / DISK_SIZE - 1
        py = ((y - DISK_TOP) * 2) / DISK_SIZE - 1
        mag_sq = px * px + py * py

        if mag_sq > 1
          c.unset(x, y)
          next
        end

        # Latitude/longitude method
        width_at_height = Math.sqrt(1 - py * py)
        px = Math.asin(px / width_at_height) * 2 / Math::PI
        py = Math.asin(py) * 2 / Math::PI
        u = frame * speed + (px + 1) * (planet.height / 2)
        v = (py + 1) * (planet.height / 2)
        u = u % planet.width
        color = planet[u.to_i, v.to_i].to_rgb8
        c.set(x, y, color)
      end
    end

    print "\e[0;0H"
    print c.render
    amount_to_sleep = Math.max(1/20 - (Time.utc - start).total_seconds, 0)
    sleep amount_to_sleep
    frame += 1
  end
end

PLANETS = [
  "earth",
  "mars",
  "moon",
]

chosen_planet = "earth"
chosen_speed = 1

OptionParser.parse do |parser|
  parser.banner = "Usage: planet [arguments]"
  parser.on("-p PLANET", "--planet=PLANET", "Planet (possible planets: #{PLANETS.join(", ")})") { |planet| chosen_planet = planet }
  parser.on("-r ROTATION_SPEED", "--rotation-speed=ROTATION_SPEED", "Speed to rotaton the planet (>=1)") { |speed| chosen_speed = speed.to_i }
  parser.on("-h", "--help", "Show this help") { puts parser }
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

run_animation(chosen_planet, chosen_speed)
