import fenstim

var 
  app = init(Fenster, "Colorful patterns", 320, 240)
  t = 1

while app.loop and app.keys[27] == 0:
  t += 1
  for i in 0..<app.width:
    for j in 0..<app.height:
      app.pixel(i, j) = (i * j * t).uint32