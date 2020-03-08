require "../src/drawille-cr"

c = DrawilleCanvas.new

(0..180).each do |x|
  c.set(x, (10 + Math.sin(x * 2 / Math::PI * 10) * 10).to_i32)
end

print c.render
