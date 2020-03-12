# Rotating planet renderer for the Terminal
# As described from https://gamedev.stackexchange.com/a/147216
require "stumpy_jpeg"
require "colorize"
require "option_parser"
require "../src/drawille-cr"

class PlanetExample
  def get_sizes(c)
    scale_coeff = 0.8
    disk_size = (Math.min(c.viewport_width, c.viewport_height) * scale_coeff).to_i32
    disk_top = (c.viewport_height - disk_size) // 2
    disk_left = (c.viewport_width - disk_size) // 2
    disk_bottom = disk_top + disk_size
    disk_right = disk_left + disk_size
    {disk_size, disk_top, disk_left, disk_bottom, disk_right}
  end

  def draw_frame(c, planet_texture, frame, speed)
    c.clear
    disk_size, disk_top, disk_left, disk_bottom, disk_right = get_sizes(c)
    (disk_left...disk_right).each do |x|
      (disk_top...disk_bottom).each do |y|
        px = ((x - disk_left) * 2) / disk_size - 1
        py = ((y - disk_top) * 2) / disk_size - 1
        mag_sq = px * px + py * py

        if mag_sq > 1
          c.unset(x, y)
          next
        end

        # Latitude/longitude method
        width_at_height = Math.sqrt(1 - py * py)
        px = Math.asin(px / width_at_height) * 2 / Math::PI
        py = Math.asin(py) * 2 / Math::PI
        u = frame * speed + (px + 1) * (planet_texture.height / 2)
        v = (py + 1) * (planet_texture.height / 2)
        u = u % planet_texture.width
        begin
          color = planet_texture[u.to_i, v.to_i].to_rgb8
          c.set(x, y, color)
        rescue
        end
      end
    end
    c.render
  end

  def get_planet_texture(planet)
    StumpyJPEG.read("examples/textures/#{planet}.jpg")
  end

  def run_animation(planet, speed, fps)
    c = Drawille::Canvas.new
    planet_texture = get_planet_texture(planet)
    c.animate do |frame|
      draw_frame(c, planet_texture, frame, speed)
    end
  end
end
