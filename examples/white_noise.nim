import fenstim, random

var app = init(Fenster, "White noise with fenstim", 800, 600)

while app.loop and app.keys[27] == 0:
  for x in 0 ..< app.width:
    for y in 0 ..< app.height:
      app.pixel(x, y) = rand(uint32)