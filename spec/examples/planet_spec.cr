require "spec"
require "../../examples/planet"

describe PlanetExample do
  describe "#size" do
    planet_example = PlanetExample.new
    planet_texture = planet_example.get_planet_texture("earth")
    (20...40).each do |terminal_lines|
      (40...80).each do |terminal_columns|
        it "renders planet in #{terminal_columns}x#{terminal_lines}=#{terminal_columns*terminal_lines} terminal" do
          c = Drawille::Canvas.new(terminal_lines, terminal_columns)
          planet_example.draw_frame(c, planet_texture, 0, 10)
        end
      end
    end
  end
end
