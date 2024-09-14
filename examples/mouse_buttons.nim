import fenstim, strutils

var 
  app = init(Fenster, "Mouse Buttons test", 800, 600)
  oldmouse = app.mouse

while app.loop and app.keys[27] == 0:
  if oldmouse != app.mouse:
    oldmouse = app.mouse
    echo app.mouse
