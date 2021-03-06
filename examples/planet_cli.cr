require "./planet"

PLANETS = [
  "earth",
  "mars",
  "moon",
]

chosen_planet = "earth"
chosen_speed = 1
chosen_fps = 20
chosen_reverse = false

OptionParser.parse do |parser|
  parser.banner = "Usage: planet [arguments]"
  parser.on("-p PLANET", "--planet=PLANET", "Planet (possible planets: #{PLANETS.join(", ")})") { |planet| chosen_planet = planet }
  parser.on("-s SPEED", "--speed=SPEED", "Speed to rotation the planet (>=1)") { |speed| chosen_speed = speed.to_i }
  parser.on("-f FPS", "--frames-per-secon=FPS", "Frames per second (>=1)") { |fps| chosen_fps = fps.to_i }
  parser.on("-r", "--reverse", "Reverses the rotation direction. Not specified will rotate counterclockwise.") { chosen_reverse = true }
  parser.on("-h", "--help", "Show this help") {
    puts parser
    exit 0
  }
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

planet_example = PlanetExample.new
planet_example.run_animation(chosen_planet, chosen_speed, chosen_fps, chosen_reverse)
