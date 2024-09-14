import fenstim

var app = init(Fenster, "Red square with fenstim", 800, 600)

while app.loop and app.keys[27] == 0:
  for x in 350 .. 450:
    for y in 250 .. 350:
      #You can alternatively enter “0xFF0000” but the stored value will still be decimal.
      #app.pixel(x, y) = colRed (with import colors)
      app.pixel(x, y) = 16711680