import fenstim

var app = init(Fenster, "Bubbles pattern", 320, 240)
var t = 0

while app.loop and app.keys[27] == 0:
  inc t
  for x in 0..<app.width:
    for y in 0..<app.height:
      app.pixel(x, y) = uint32(((x * x + y * y + t) and 255) * 0x010101)